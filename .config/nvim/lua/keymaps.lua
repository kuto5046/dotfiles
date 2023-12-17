local opts = { noremap = true, silent = true }
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
-- keymap("n", "<C-W>+", ":<C-u>resize +5<CR>", { silent = true })
-- keymap("n", "<C-W>-", ":<C-u>resize -5<CR>", { silent = true })
-- keymap("n", "<C-W>>", ":<C-u>vertical resize +10<CR>", { silent = true })
-- keymap("n", "<C-W><", ":<C-u>vertical resize -10<CR>", { silent = true })

-- tab
-- keymap("n", "tn", ":tabnew<Return>", opts)
-- keymap("n", "th", "gT", opts)
-- keymap("n", "tl", "gt", opts)

-- buffer
vim.api.nvim_set_keymap("n", "J", ":bprev<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "K", ":bnext<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "X", ":bdelete<CR>", { noremap = true, silent = true })

-- terminalからescで出るようにする
keymap("t", "<esc>", [[<C-\><C-n>]], opts)

-- esc2回でハイライト解除
keymap("n", "<Esc><Esc>", ":<C-u>set nohlsearch<Return>", opts)

-- telescope
local builtin = require("telescope.builtin")
-- find系
vim.keymap.set("n", "<leader>f", builtin.find_files, {})
vim.keymap.set("n", "<leader>gg", builtin.live_grep, {})
vim.keymap.set("n", "<leader>d", builtin.diagnostics, {})
vim.keymap.set("n", "<leader>h", builtin.help_tags, {})
vim.keymap.set("n", "<leader>k", builtin.keymaps, {})
-- git系
vim.keymap.set("n", "<leader>gc", builtin.git_commits, {})
vim.keymap.set("n", "<leader>gb", builtin.git_branches, {})
vim.keymap.set("n", "<leader>gs", builtin.git_status, {})

vim.keymap.set("n", "<leader>b", function()
	require("telescope").extensions.file_browser.file_browser({
		path = "%:p:h",
		-- cwd = telescope_buffer_dir(),
		respect_gitignore = false,
		hidden = true,
		grouped = true,
		-- previewer = false,
		initial_mode = "normal",
		-- layout_config = { height = 40 }
	})
end)

vim.api.nvim_set_keymap(
	"n",
	"<leader>r",
	"<Cmd>lua require('telescope').extensions.frecency.frecency()<CR>",
	{ noremap = true, silent = true }
)
