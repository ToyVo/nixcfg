local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()
local lspconfig = require("lspconfig")
local servers = { "tsserver", "eslint", "nil_ls", "cssls", "jsonls", "html" }
for _, server in ipairs(servers) do
  lspconfig[server].setup({
    capabilities = lsp_capabilities,
  })
end
lspconfig.lua_ls.setup({
  capabilities = lsp_capabilities,
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
      },
    },
  },
})
