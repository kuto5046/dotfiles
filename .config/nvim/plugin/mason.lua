-- local status, mason = pcall(require, "mason")
-- if (not status) then return end
-- local on_attach = function(client, bufnr)

require("mason").setup()
require("mason-lspconfig").setup()

-- After setting up mason-lspconfig you may set up servers via lspconfig
require("lspconfig")["rust_analyzer"].setup {}
require("lspconfig")["pyright"].setup {}
