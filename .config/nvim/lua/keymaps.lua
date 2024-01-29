local opts = { noremap = true, silent = true }

-- #################
-- general
-- #################
--Spaceキーをleaderに設定
vim.keymap.set("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- terminalからescで出るようにする
vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
-- esc2回でハイライト解除
vim.keymap.set("n", "<Esc><Esc>", ":<C-u>set nohlsearch<Return>", opts)

-- #################
-- tab
-- #################
vim.keymap.set("n", "J", ":bprev<CR>", opts)
vim.keymap.set("n", "K", ":bnext<CR>", opts)
vim.keymap.set("n", "X", ":bdelete<CR>", opts)

if not vim.g.vscode then
	-- #################
	-- telescope
	-- #################
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
	-- frecency
	vim.keymap.set(
		"n",
		"<leader>r",
		"<Cmd>lua require('telescope').extensions.frecency.frecency()<CR>",
		{ noremap = true, silent = true }
	)

	-- #################
	-- LSP
	-- #################
	-- Global mappings.
	-- See `:help vim.diagnostic.*` for documentation on any of the below functions
	vim.keymap.set("n", "<C-d>", vim.diagnostic.open_float)
	vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
	vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
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
			local opts = { buffer = ev.buf }
			vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
			vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
			vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
			vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
			-- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
			-- vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
			-- vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
			-- vim.keymap.set('n', '<space>wl', function()
			--   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
			-- end, opts)
			vim.keymap.set("n", "<leader>lt", vim.lsp.buf.type_definition, opts)
			vim.keymap.set("n", "<snace>lr", vim.lsp.buf.rename, opts)
			vim.keymap.set({ "n", "v" }, "<space>la", vim.lsp.buf.code_action, opts)
			vim.keymap.set("n", "ff", function()
				vim.lsp.buf.format({ async = true })
			end, opts)
		end,
	})

	-- #################
	-- debuggers
	-- #################
	-- <leader>dをprefixにする(TODO: dap起動時のみ以下のkeymapを有効にする)
	vim.keymap.set("n", "<F5>", ":DapContinue<CR>", { silent = true })
	vim.keymap.set("n", "<F10>", ":DapStepOver<CR>", { silent = true })
	vim.keymap.set("n", "<F11>", ":DapStepInto<CR>", { silent = true })
	vim.keymap.set("n", "<F12>", ":DapStepOut<CR>", { silent = true })
	vim.keymap.set("n", "<leader>dt", ":DapToggleBreakpoint<CR>", { silent = true }) -- breakpointの設置/解除
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

	-- #################
	-- neotest
	-- #################
	-- (<leader>tをprefixにする)
	-- nearestのtestを実行(冒頭で実行するとファイル内の全てのtestが実行される)
	vim.keymap.set("n", "<leader>tt", ":lua require('neotest').run.run()<CR>", { silent = true })
	-- nearestのtestをdebuggerで実行(冒頭で実行するとファイル内の全てのtestが実行される)
	vim.keymap.set("n", "<leader>td", ":lua require('neotest').run.run({strategy='dap'})<CR>", { silent = true })

	-- testをwatchしコードを変更した場合自動でtestを実行
	vim.keymap.set("n", "<leader>tw", ":lua require('neotest').watch.toggle()<CR>", { silent = true })

	-- testのsummaryを表示
	vim.keymap.set("n", "<leader>ts", ":lua require('neotest').summary.toggle()<CR>", { silent = true })

	-- testのoutputを表示
	vim.keymap.set("n", "<leader>to", ":lua require('neotest').output.open({auto_close=true})<CR>", { silent = true })

	-- testのoutputをpanelで表示
	vim.keymap.set("n", "<leader>tp", ":lua require('neotest').output_panel.toggle()<CR>", { silent = true })
end
