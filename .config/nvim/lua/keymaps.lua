local opts = { noremap = true, silent = true }
local term_opts = { silent = true }

local keymap = vim.api.nvim_set_keymap

--Spaceキーをleaderに設定
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Modes
--   normal_mode = 'n',
--   insert_mode = 'i',
--   visual_mode = 'v',
--   visual_block_mode = 'x',
--   term_mode = 't',
--   command_mode = 'c',

-- window
keymap('n', '<C-W>+', ':<C-u>resize +5<CR>', { silent = true })
keymap('n', '<C-W>-', ':<C-u>resize -5<CR>', { silent = true })
keymap('n', '<C-W>>', ':<C-u>vertical resize +10<CR>', { silent = true })
keymap('n', '<C-W><', ':<C-u>vertical resize -10<CR>', { silent = true })

-- tab
-- keymap("n", "tn", ":tabnew<Return>", opts)
-- keymap("n", "th", "gT", opts)
-- keymap("n", "tl", "gt", opts)

-- terminalからescで出るようにする
keymap("t", "<esc>", [[<C-\><C-n>]], opts)

-- esc2回でハイライト解除
keymap("n", "<Esc><Esc>", ":<C-u>set nohlsearch<Return>", opts)
