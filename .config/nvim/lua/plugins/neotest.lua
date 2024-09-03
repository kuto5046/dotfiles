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
	end,
}
