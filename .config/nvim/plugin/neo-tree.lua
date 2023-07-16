require("neo-tree").setup({
  enable_git_status = true,
  enable_diagnostics = true,
  filesystem = {
    filtered_items = {
      hide_dotfiles = false,
      hide_gitignored = false,
    }
  }
})
vim.api.nvim_set_keymap('n', '<C-b>', ':Neotree toggle<Return>', {noremap = true})

