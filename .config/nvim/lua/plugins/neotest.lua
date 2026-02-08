return {
	"nvim-neotest/neotest",
	lazy = true,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		"nvim-neotest/neotest-python",
		"nvim-neotest/neotest-plenary",
		"nvim-neotest/nvim-nio",
	},
	keys = {
		{
			"<leader>tt",
			function()
				require("neotest").run.run()
			end,
			desc = "Run nearest test",
		},
		{
			"<leader>td",
			function()
				require("neotest").run.run({ strategy = "dap" })
			end,
			desc = "Debug nearest test",
		},
		{
			"<leader>tw",
			function()
				require("neotest").watch.toggle()
			end,
			desc = "Toggle test watch",
		},
		{
			"<leader>ts",
			function()
				require("neotest").summary.toggle()
			end,
			desc = "Toggle test summary",
		},
		{
			"<leader>to",
			function()
				require("neotest").output.open({ auto_close = true })
			end,
			desc = "Open test output",
		},
		{
			"<leader>tp",
			function()
				require("neotest").output_panel.toggle()
			end,
			desc = "Toggle test output panel",
		},
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
	end,
}
