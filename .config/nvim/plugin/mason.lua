require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = {
    "pyright",
    "rust_analyzer",
    "lua_ls",
  }
})

-- After setting up mason-lspconfig you may set up servers via lspconfig
require("lspconfig")["lua_ls"].setup({})
require("lspconfig")["rust_analyzer"].setup({})

-- poetryに対応
require("lspconfig")["pyright"].setup {
  on_atatch = on_attach,
    settings = {
      python = {
        venvPath = ".",
        pythonPath = "./.venv/bin/python",
        analysis = {
          extraPaths = {"."}
      }
    }
  }
}
