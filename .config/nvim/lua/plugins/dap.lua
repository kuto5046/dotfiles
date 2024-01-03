return {
	{
		"mfussenegger/nvim-dap",
	},
	{
		"mfussenegger/nvim-dap-python",
		config = function()
			-- 仮想環境を自動で認識する
			-- vimに入る前に仮想環境をactivateしておく必要がある
			local venv = os.getenv("VIRTUAL_ENV")
			local command = string.format("%s/bin/python", venv)
			require("dap-python").setup(command)
		end,
	},
	-- vscodeのようなUIを提供する
	{
		"rcarriga/nvim-dap-ui",
		config = function()
			require("dapui").setup({})
		end,
	},
	-- dap-uiで型チェックを有効にするために推奨されている
	{
		"folke/neodev.nvim",
		config = function()
			require("neodev").setup({
				library = { plugins = { "nvim-dap-ui" }, types = true },
			})
		end,
	},
	-- debug時に変数の値やdebug情報を表示する
	{
		"theHamsta/nvim-dap-virtual-text",
		config = function()
			require("nvim-dap-virtual-text").setup({})
		end,
	},
}
