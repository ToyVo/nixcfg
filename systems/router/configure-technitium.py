import json, os, sys, time, urllib.request as u, urllib.parse as p

url = os.environ.get("TECHNITIUM_URL", "http://127.0.0.1:5380")
token_file = os.environ.get("TECHNITIUM_TOKEN_FILE", "")
admin_user = os.environ.get("TECHNITIUM_ADMIN_USER", "admin")
admin_pass_file = os.environ.get("TECHNITIUM_ADMIN_PASS_FILE", "")

# Read files if they exist
def read_file(path):
    if path and os.path.exists(path):
        try:
            with open(path) as f:
                return f.read().strip()
        except Exception as e:
            print(f"Warning: could not read {path}: {e}", file=sys.stderr)
    return ""

token = read_file(token_file)
admin_pass = read_file(admin_pass_file) or "admin"

# ---------------------------------------------------------------------------
# Low-level HTTP helpers
# ---------------------------------------------------------------------------

def request(ep, data=None, method="GET", auth_token=None):
    """Make an API request. Returns parsed JSON dict or None on failure."""
    headers = {}
    if auth_token:
        headers["Authorization"] = "Bearer " + auth_token
    if data:
        body = p.urlencode(data).encode()
        headers["Content-Type"] = "application/x-www-form-urlencoded"
        req = u.Request(url + ep, data=body, headers=headers, method=method)
    else:
        req = u.Request(url + ep, headers=headers, method=method)
    try:
        with u.urlopen(req, timeout=30) as resp:
            return json.loads(resp.read().decode())
    except Exception as e:
        print(f"  HTTP error on {ep}: {e}", file=sys.stderr)
        return None


def is_ok(resp):
    """True if response is a dict with status == 'ok'."""
    return isinstance(resp, dict) and resp.get("status") == "ok"


def is_invalid_token(resp):
    """True if response indicates an auth failure."""
    return isinstance(resp, dict) and resp.get("status") == "invalid-token"


# ---------------------------------------------------------------------------
# Auth: try existing token → admin login → fail
# ---------------------------------------------------------------------------

def get_auth_token():
    """
    Return a working API/session token.
    1. If a token file is provided and works, use it.
    2. Otherwise try admin/admin login.
    3. Otherwise try token-file contents as admin password.
    """
    # 1. Try token file content as a Bearer token
    if token:
        print(f"Trying token from {token_file} ...")
        resp = request("/api/stats", auth_token=token)
        if is_ok(resp):
            print("Token authenticated successfully.")
            return token
        elif is_invalid_token(resp):
            print("Token rejected (invalid-token).")
        else:
            print(f"Token auth failed: {resp}")

    # 2. Try admin password from sops secret (or default "admin")
    print(f"Trying login with {admin_user}/<password-from-file> ...")
    login = request("/api/user/login", {"user": admin_user, "pass": admin_pass}, "POST")
    if is_ok(login) and login.get("token"):
        print("Login successful.")
        return login["token"]
    else:
        print(f"Login failed: {login}")

    print("FATAL: Could not authenticate with Technitium API.", file=sys.stderr)
    print("  - Put the admin password in the sops secret 'technitium_admin_password'.", file=sys.stderr)
    print("  - Or generate an API token via the web UI and save it to the sops secret 'technitium_api_key'.", file=sys.stderr)
    return None


# ---------------------------------------------------------------------------
# Wait for API to be reachable (unauthenticated health check)
# ---------------------------------------------------------------------------

def wait_for_api(max_wait=120):
    """Poll /api/stats without auth until it responds (any response = up)."""
    for i in range(max_wait):
        try:
            req = u.Request(url + "/api/stats", method="GET")
            with u.urlopen(req, timeout=5) as resp:
                # We got any HTTP response — API is up.  We don't care about
                # the JSON body here; auth is handled separately.
                return True
        except Exception:
            pass
        time.sleep(1)
    return False


# ---------------------------------------------------------------------------
# Configuration helpers
# ---------------------------------------------------------------------------

def zone(t):
    print("Creating zone diekvoss.net ...")
    r = request("/api/zones/create", {"zone": "diekvoss.net", "type": "Primary"}, "POST", t)
    if not is_ok(r):
        # Zone may already exist; that's fine.
        if isinstance(r, dict) and "already exists" in r.get("errorMessage", "").lower():
            print("  Zone already exists, continuing.")
        else:
            print(f"  Warning: zone create failed: {r}")

    records = json.loads(os.environ.get("TECHNITIUM_ZONE_RECORDS", "[]"))
    for rec in records:
        print(f"  Adding record: {rec.get('name','@')} {rec.get('type','A')} {rec.get('value','')} ...")
        r = request("/api/zones/records/add", rec, "POST", t)
        if not is_ok(r):
            # Ignore "already exists" errors
            msg = str(r.get("errorMessage", "")) if isinstance(r, dict) else ""
            if "already exists" in msg.lower() or "duplicate" in msg.lower():
                print(f"    Already exists, skipped.")
            else:
                print(f"    ERROR: {r}")


def blocklists(t):
    urls = json.loads(os.environ.get("TECHNITIUM_BLOCKLISTS", "[]"))
    if not urls:
        return
    print("Configuring blocklists ...")
    # Try the most common API endpoints Technitium uses for blocklists.
    # The exact endpoint varies by version; we try them all.
    endpoints = [
        "/api/settings/set",
        "/api/blockList/urls/add",
        "/api/blockList/urls/set",
        "/api/apps/config",
    ]
    params = ["blockListUrl", "url", "urls", "blockListUrls"]
    for block_url in urls:
        print(f"  Adding blocklist: {block_url}")
        added = False
        for ep in endpoints:
            for pr in params:
                r = request(ep, {pr: block_url}, "POST", t)
                if is_ok(r):
                    print(f"    OK via {ep}?{pr}")
                    added = True
                    break
                elif isinstance(r, dict) and r.get("status") == "error":
                    msg = r.get("errorMessage", "")
                    if "already exists" in msg.lower() or "duplicate" in msg.lower():
                        print(f"    Already exists, skipped.")
                        added = True
                        break
                    # Otherwise keep trying other endpoints
            if added:
                break
        if not added:
            print(f"    WARNING: could not add blocklist via any known endpoint", file=sys.stderr)


def forwarders(t):
    fwds = json.loads(os.environ.get("TECHNITIUM_FORWARDERS", "[]"))
    if not fwds:
        return
    print("Configuring forwarders ...")
    endpoints = [
        "/api/settings/set",
        "/api/forwarders/add",
        "/api/forwarders/set",
    ]
    params = ["forwarder", "address", "forwarders"]
    for fwd in fwds:
        print(f"  Adding forwarder: {fwd}")
        added = False
        for ep in endpoints:
            for pr in params:
                r = request(ep, {pr: fwd}, "POST", t)
                if is_ok(r):
                    print(f"    OK via {ep}?{pr}")
                    added = True
                    break
                elif isinstance(r, dict) and r.get("status") == "error":
                    msg = r.get("errorMessage", "")
                    if "already exists" in msg.lower() or "duplicate" in msg.lower():
                        print(f"    Already exists, skipped.")
                        added = True
                        break
            if added:
                break
        if not added:
            print(f"    WARNING: could not add forwarder via any known endpoint", file=sys.stderr)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    print(f"Waiting for Technitium API at {url} ...")
    if not wait_for_api():
        print("FATAL: Technitium API did not become reachable within 120 seconds.", file=sys.stderr)
        sys.exit(1)
    print("API is reachable.")

    t = get_auth_token()
    if not t:
        sys.exit(1)

    zone(t)
    blocklists(t)
    forwarders(t)

    print("Technitium configuration complete.")
