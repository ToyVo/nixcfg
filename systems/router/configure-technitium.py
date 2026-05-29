import json, os, sys, time, urllib.request as u, urllib.parse as p
url = os.environ.get("TECHNITIUM_URL", "http://127.0.0.1:5380")
f = os.environ.get("TECHNITIUM_TOKEN_FILE", "")
t = open(f).read().strip() if f and os.path.exists(f) else ""
def call(ep, d=None, m="GET"):
    h = {"Authorization": "Bearer " + t} if t else {}
    if d:
        b = p.urlencode(d).encode()
        h["Content-Type"] = "application/x-www-form-urlencoded"
        r = u.Request(url + ep, data=b, headers=h, method=m)
    else:
        r = u.Request(url + ep, headers=h, method=m)
    try:
        return json.loads(u.urlopen(r, timeout=30).read().decode())
    except Exception as e:
        print(f"Error {ep}: {e}", file=sys.stderr)
        return None
def wait():
    for _ in range(120):
        try:
            u.urlopen(u.Request(url + "/api/stats", headers={"Authorization": "Bearer " + t} if t else {}), timeout=5)
            return True
        except: pass
        time.sleep(1)
    return False
def zone():
    call("/api/zones/create", {"zone": "diekvoss.net", "type": "Primary"}, "POST")
    for rec in json.loads(os.environ.get("TECHNITIUM_ZONE_RECORDS", "[]")):
        call("/api/zones/records/add", rec, "POST")
def bl():
    for x in json.loads(os.environ.get("TECHNITIUM_BLOCKLISTS", "[]")):
        for ep in ["/api/settings/set", "/api/blockList/urls/add"]:
            for pr in ["blockListUrl", "url"]:
                if call(ep, {pr: x}, "POST"): break
            else: continue
            break
def fw():
    for x in json.loads(os.environ.get("TECHNITIUM_FORWARDERS", "[]")):
        for ep in ["/api/settings/set", "/api/forwarders/add"]:
            for pr in ["forwarder", "address"]:
                if call(ep, {pr: x}, "POST"): break
            else: continue
            break
if not wait(): sys.exit(1)
zone(); bl(); fw()
