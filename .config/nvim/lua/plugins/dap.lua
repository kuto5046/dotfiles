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
			vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DapBreakpoint" })
			vim.fn.sign_define("DapStopped", { text = "", texthl = "DapStopped", culhl = "DapStopped" })
			vim.fn.sign_define("DapBreakooibtCondition", { text = "", texthl = "DapBreakpoint" })
			vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DapLogPoint" })
			vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DapBreakpoint" })
			-- 赤色にする
			vim.cmd([[highlight DapBreakpoint guifg=#993939]])
			vim.cmd([[highlight DapStopped guifg=#993939 ]])
			vim.cmd([[highlight DapBreakooibtCondition guifg=#993939]])
			vim.cmd([[highlight DapLogPoint guifg=#993939]])
			vim.cmd([[highlight DapBreakpointRejected guifg=#993939]])
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
