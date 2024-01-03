local opts = { noremap = true, silent = true }

--Spaceキーをleaderに設定
vim.keymap.set("", "<Space>", "<Nop>", opts)
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
vim.keymap.set("n", "J", ":bprev<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "K", ":bnext<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "X", ":bdelete<CR>", { noremap = true, silent = true })

-- terminalからescで出るようにする
vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)

-- esc2回でハイライト解除
vim.keymap.set("n", "<Esc><Esc>", ":<C-u>set nohlsearch<Return>", opts)

-- telescope
local builtin = require("telescope.builtin")
-- find系
vim.keymap.set("n", "<leader>f", builtin.find_files, {})
vim.keymap.set("n", "<leader>gg", builtin.live_grep, {})
vim.keymap.set("n", "<leader>e", builtin.diagnostics, {})
vim.keymap.set("n", "<leader>h", builtin.help_tags, {})
vim.keymap.set("n", "<leader>k", builtin.keymaps, {})
-- git系
vim.keymap.set("n", "<leader>gc", builtin.git_commits, {})
vim.keymap.set("n", "<leader>gb", builtin.git_branches, {})
vim.keymap.set("n", "<leader>gs", builtin.git_status, {})
-- notify
vim.keymap.set("n", "<leader>n", function()
	require("telescope").extensions.notify.notify({
		initial_mode = "normal",
	})
end)
-- browser
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

vim.keymap.set(
	"n",
	"<leader>r",
	"<Cmd>lua require('telescope').extensions.frecency.frecency()<CR>",
	{ noremap = true, silent = true }
)

-- debuggers(like vscode)
-- <leader>dをprefixにする
vim.keymap.set("n", "<F5>", ":DapContinue<CR>", { silent = true })
vim.keymap.set("n", "<F10>", ":DapStepOver<CR>", { silent = true })
vim.keymap.set("n", "<F11>", ":DapStepInto<CR>", { silent = true })
vim.keymap.set("n", "<F12>", ":DapStepOut<CR>", { silent = true })
vim.keymap.set("n", "<leader>dt", ":DapToggleBreakpoint<CR>", { silent = true }) -- breakpointの設置/解除
-- breakpointのconditionとlog pointの設定(TODO: 正しく設定できていない)
vim.keymap.set(
	"n",
	"<leader>dc",
	':lua require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>',
	{ silent = true }
)
vim.keymap.set(
	"n",
	"<leader>dm",
	':lua require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))<CR>',
	{ silent = true }
)
vim.keymap.set("n", "<leader>dd", ':lua require("dapui").toggle()<CR>', {}) -- dapuiの起動
vim.keymap.set("n", "<leader>df", ":lua require('dapui').eval()<CR>", { silent = true }) -- floating windowで変数の値を表示
