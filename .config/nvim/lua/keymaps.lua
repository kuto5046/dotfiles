local opts = { noremap = true, silent = true }

-- #################
-- general
-- #################
-- terminalからjkで出るようにする（escはClaude Codeの生成停止用に残す）
vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
-- esc2回でハイライト解除
vim.keymap.set(
	"n",
	"<Esc><Esc>",
	":<C-u>set nohlsearch<Return>",
	{ noremap = true, silent = true, desc = "Clear search highlight" }
)

-- #################
-- buffer
-- #################
vim.keymap.set("n", "J", ":bprev<CR>", { noremap = true, silent = true, desc = "Previous buffer" })
vim.keymap.set("n", "K", ":bnext<CR>", { noremap = true, silent = true, desc = "Next buffer" })
vim.keymap.set("n", "X", ":bdelete<CR>", { noremap = true, silent = true, desc = "Close buffer" })
