return {
	{
		"zbirenbaum/copilot.lua",
		config = function()
			require("copilot").setup({
				-- copilot-cmpと衝突するためfalseとする
				suggestion = { enabled = false },
				panel = { enabled = false },
			})
		end,
	},
	{
		"zbirenbaum/copilot-cmp",
		config = function()
			require("copilot_cmp").setup({})
		end,
	}, -- copilot completions
	{
		"jonahgoldwastaken/copilot-status.nvim",
		dependencies = { "zbirenbaum/copilot.lua" },
		config = function()
			require("copilot_status").setup({
				icons = {
					idle = "",
					error = " ",
					offline = " ",
					warning = "𥉉",
					loading = " ",
				},
				debug = false,
			})
		end,
		-- lazy = true,
		-- event = "BufReadPost",
	}, -- copilot status
}
