return {
	"NeogitOrg/neogit",
	lazy = true,
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
		"esmuellert/codediff.nvim", -- optional
		"nvim-telescope/telescope.nvim", -- optional
		"folke/snacks.nvim", -- optional
	},
	cmd = "Neogit",
	keys = {
		{ "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogitを開く" },
	},
	config = function()
		require("neogit").setup({
			integrations = {
				diffview = false,
				codediff = true,
				snacks = true,
			},
		})
	end,
}
