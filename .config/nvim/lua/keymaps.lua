local opts = { noremap = true, silent = true }

-- #################
-- general
-- #################
-- terminalからescで出るようにする
vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
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

-- #################
-- telescope
-- #################
local builtin = require("telescope.builtin")

-- find系
vim.keymap.set("n", "<leader>f", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>gg", builtin.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>e", builtin.diagnostics, { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>h", builtin.help_tags, { desc = "Help tags" })
vim.keymap.set("n", "<leader>k", builtin.keymaps, { desc = "Keymaps" })
-- git系
vim.keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "Git commits" })
vim.keymap.set("n", "<leader>gb", builtin.git_branches, { desc = "Git branches" })
vim.keymap.set("n", "<leader>gs", builtin.git_status, { desc = "Git status" })
vim.keymap.set("n", "<leader>gl", function()
	require("snacks").lazygit()
end, { desc = "Lazygit" })
-- diff
vim.keymap.set("n", "<leader>vd", "<cmd>DiffviewOpen <CR>", { noremap = true, silent = true, desc = "Diffview" })
-- 開いているファイルのhistoryを表示
vim.keymap.set(
	"n",
	"<leader>vh",
	"<cmd>DiffviewFileHistory %<CR>",
	{ noremap = true, silent = true, desc = "Diffview file history" }
)

-- venv
vim.keymap.set("n", "<leader>p", "<cmd>VenvSelect<CR>", { noremap = true, silent = true, desc = "Python Venv select" })
-- notify
vim.keymap.set("n", "<leader>n", function()
	require("telescope").extensions.notify.notify({
		initial_mode = "normal",
	})
end, { desc = "Notify" })

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
end, { desc = "File browser" })
-- frecency
vim.keymap.set(
	"n",
	"<leader>r",
	"<Cmd>lua require('telescope').extensions.frecency.frecency()<CR>",
	{ noremap = true, silent = true, desc = "Telescope Frecency" }
)

-- #################
-- LSP
-- #################
-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
-- vim.keymap.set("n", "<C-d>", vim.diagnostic.open_float)
-- vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
-- vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
-- vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		-- Enable completion triggered by <c-x><c-o>
		vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

		-- Buffer local mappings.
		-- See `:help vim.lsp.*` for documentation on any of the below functions
		-- vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = ev.buf, desc = "Go to declaration" })  -- 定義ジャンプと同じ
		-- vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "Go to definition" })
		vim.keymap.set(
			"n",
			"gd",
			":vsplit | lua vim.lsp.buf.definition()<CR>",
			{ buffer = ev.buf, desc = "Go to definition" }
		)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = ev.buf, desc = "Show hover" })
		vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = ev.buf, desc = "Go to references" }) -- TODO: 毎回windowが開くので手動で消す必要があり面倒
		-- vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts, { buffer = ev.buf, desc = "Go to implementation" })  -- pythonでは不要
		-- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
		-- vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
		-- vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
		-- vim.keymap.set('n', '<space>wl', function()
		--   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		-- end, opts)
		-- vim.keymap.set("n", "<leader>lt", vim.lsp.buf.type_definition, opts)  -- pythonだと定義ジャンプと同じっぽい
		vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, { buffer = ev.buf, desc = "Rename" })
		-- vim.keymap.set({ "n", "v" }, "<space>la", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "ff", function()
			vim.lsp.buf.format({ async = true })
		end, { buffer = ev.buf, desc = "Format" })
	end,
})

-- #################
-- debuggers
-- #################
-- <leader>dをprefixにする(TODO: dap起動時のみ以下のkeymapを有効にする)
vim.keymap.set("n", "<F5>", ":DapContinue<CR>", { silent = true, desc = "Debug Continue" })
vim.keymap.set("n", "<F10>", ":DapStepOver<CR>", { silent = true, desc = "Debug Step over" })
vim.keymap.set("n", "<F11>", ":DapStepInto<CR>", { silent = true, desc = "Debug Step into" })
vim.keymap.set("n", "<F12>", ":DapStepOut<CR>", { silent = true, desc = "Debug Step out" })
vim.keymap.set("n", "<leader>dt", ":DapToggleBreakpoint<CR>", { silent = true, desc = "Debug Toggle Breakpoint" }) -- breakpointの設置/解除
vim.keymap.set(
	"n",
	"<leader>dc",
	':lua require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>',
	{ silent = true, desc = "Debug Set Breakpoint with condition" }
)
vim.keymap.set(
	"n",
	"<leader>dm",
	':lua require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))<CR>',
	{ silent = true, desc = "Debug Set Log point" }
)
vim.keymap.set("n", "<leader>dd", ':lua require("dapui").toggle()<CR>', { desc = "Start Debug UI" }) -- dapuiの起動
vim.keymap.set("n", "<leader>df", ":lua require('dapui').eval()<CR>", { silent = true, desc = "Show variable" }) -- floating windowで変数の値を表示

-- #################
-- neotest
-- #################
-- (<leader>tをprefixにする)
-- nearestのtestを実行(冒頭で実行するとファイル内の全てのtestが実行される)
vim.keymap.set("n", "<leader>tt", ":lua require('neotest').run.run()<CR>", { silent = true, desc = "Run nearest test" })
-- nearestのtestをdebuggerで実行(冒頭で実行するとファイル内の全てのtestが実行される)
vim.keymap.set(
	"n",
	"<leader>td",
	":lua require('neotest').run.run({strategy='dap'})<CR>",
	{ silent = true, desc = "Debug nearest test" }
)

-- testをwatchしコードを変更した場合自動でtestを実行
vim.keymap.set(
	"n",
	"<leader>tw",
	":lua require('neotest').watch.toggle()<CR>",
	{ silent = true, desc = "Toggle test watch" }
)

-- testのsummaryを表示
vim.keymap.set(
	"n",
	"<leader>ts",
	":lua require('neotest').summary.toggle()<CR>",
	{ silent = true, desc = "Toggle test summary" }
)

-- testのoutputを表示
vim.keymap.set(
	"n",
	"<leader>to",
	":lua require('neotest').output.open({auto_close=true})<CR>",
	{ silent = true, desc = "Open test output" }
)

-- testのoutputをpanelで表示
vim.keymap.set(
	"n",
	"<leader>tp",
	":lua require('neotest').output_panel.toggle()<CR>",
	{ silent = true, desc = "Toggle test output panel" }
)
