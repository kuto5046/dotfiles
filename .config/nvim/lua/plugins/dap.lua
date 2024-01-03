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
			vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DapBreakpoint" })
			vim.fn.sign_define(
				"DapStopped",
				{ text = "", texthl = "DapBreakpoint", linehl = "DapStopped", numhl = "DapStopped" }
			)
			vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DapBreakpoint" })
			vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DapBreakpoint" })
			vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DapBreakpointRejected" })
			-- 赤色にする
			vim.cmd([[highlight DapBreakpoint guifg='#c94f6d']])
			vim.cmd([[highlight DapBreakpointRejected guifg='Grey']])
			-- 現在停止中のbreakpointのhighlightを透過させる
			local utils = require("../utils")
			local normal_bg = utils.get_bg("Normal", "Normal")
			local opacity = 0.4
			-- yellowの少し薄めの色は#f0f0a0
			local bg = utils.blend("#f0f0a0", normal_bg, opacity)
			vim.cmd("hi DapStopped guibg=" .. bg)
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
