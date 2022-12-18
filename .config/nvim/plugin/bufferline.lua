require("bufferline").setup{}

local keymap = vim.api.nvim_set_keymap
keymap('n', '<Tab>', '<Cmd>BufferLineCycleNext<CR>', {})
keymap('n', '<S-Tab>', '<Cmd>BufferLineCyclePrev<CR>', {})
