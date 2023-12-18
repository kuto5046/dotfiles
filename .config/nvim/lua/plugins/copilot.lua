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
}
