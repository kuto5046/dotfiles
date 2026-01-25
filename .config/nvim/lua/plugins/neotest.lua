return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		"nvim-neotest/neotest-python",
		"nvim-neotest/neotest-plenary",
		"nvim-neotest/nvim-nio",
	},
	config = function()
		-- 仮想環境を自動で認識する
		-- vimに入る前に仮想環境をactivateしておく必要がある
		local venv = os.getenv("VIRTUAL_ENV")
		local venv_path = string.format("%s/bin/python", venv)
		require("neotest").setup({
			adapters = {
				require("neotest-python")({
					dap = { justMyCode = true },
					runner = "pytest",
					python = venv_path,
				}),
				require("neotest-plenary"),
			},
		})

		-- Keymaps (<leader>tをprefixにする)
		-- nearestのtestを実行(冒頭で実行するとファイル内の全てのtestが実行される)
		vim.keymap.set(
			"n",
			"<leader>tt",
			":lua require('neotest').run.run()<CR>",
			{ silent = true, desc = "Run nearest test" }
		)
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
	end,
}
