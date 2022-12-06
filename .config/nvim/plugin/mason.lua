-- local status, mason = pcall(require, "mason")
-- if (not status) then return end
-- local on_attach = function(client, bufnr)

require('mason').setup()
require('mason-lspconfig').setup_handlers({ function(server)
  local opt = {
    on_attach = function(client, bufnr)
      local opts = { noremap=true, silent=true }
      vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gf', '<cmd>lua vim.lsp.buf.format {async=true}<CR>', opts)

      vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
      vim.api.nvim_buf_set_keymap(bufnr, "n", 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
      vim.api.nvim_buf_set_keymap(bufnr, "n", 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)

      vim.api.nvim_buf_set_keymap(bufnr, 'n', 'ge', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', ']e', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', '[e', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)

      vim.cmd [[
      let s:bl = ['json'] " set blacklist filetype
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold,CursorHoldI <buffer> if index(s:bl, &ft) < 0 | lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved,CursorMovedI <buffer> if index(s:bl, &ft) < 0 | lua vim.lsp.buf.clear_references()
      augroup END
      ]]
    end,
    capabilities = require('cmp_nvim_lsp').default_capabilities(
      vim.lsp.protocol.make_client_capabilities()
    )
  }
  require('lspconfig')[server].setup(opt)
end })



-- After setting up mason-lspconfig you may set up servers via lspconfig
require("lspconfig")["rust_analyzer"].setup {
  on_attach = on_attach
}

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
