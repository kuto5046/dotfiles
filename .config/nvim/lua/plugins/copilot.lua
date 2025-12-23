return {
	{
		"zbirenbaum/copilot.lua",
		enabled = false,
		lazy = true,
		event = "InsertEnter",
		config = function()
			require("copilot").setup({

				-- こちらはvscodeのようにコード上に直接提案する
				suggestion = {
					enabled = true,
					auto_trigger = true,
					-- 下でkeymapを設定しているためここではfalseとする
					keymap = {
						accept = false,
					},
				},
				panel = { enabled = true },
				filetypes = {
					markdown = true,
					gitcommit = true,
				},
			})
		end,
	},
	{
		-- suggestionされている時のみTabでacceptする
		vim.keymap.set("i", "<Tab>", function()
			if require("copilot.suggestion").is_visible() then
				require("copilot.suggestion").accept()
			else
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
			end
		end, {
			silent = true,
		}),
	},
	{
		"zbirenbaum/copilot-cmp",
		config = function()
			require("copilot_cmp").setup({})
		end,
	}, -- copilot completions
}
