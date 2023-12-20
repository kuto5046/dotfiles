return {
	{
		"zbirenbaum/copilot.lua",
		lazy = true,
		event = "InsertEnter",
		config = function()
			require("copilot").setup({

				-- こちらはvscodeのようにコード上に直接提案する
				suggestion = {
					enabled = true,
					auto_trigger = true,
					keymap = {
						accept = "<Tab>",
					},
				},
				-- こっちはpopupで提案するがsuggestのみで良いためfalseとする
				panel = { enabled = false },
				filetypes = {
					markdown = true,
					gitcommit = true,
				},
			})
		end,
	},
	-- vscodeのようにsuggestのみで良いためcmpは不要
	-- {
	-- 	"zbirenbaum/copilot-cmp",
	-- 	config = function()
	-- 		require("copilot_cmp").setup({})
	-- 	end,
	-- }, -- copilot completions
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
		lazy = true,
		event = "BufReadPost",
	}, -- copilot status
}
