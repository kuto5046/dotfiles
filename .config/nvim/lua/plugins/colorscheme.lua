return {
	{ "EdenEast/nightfox.nvim" },
	{ "cocopon/iceberg.vim" },
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				integrations = {
					cmp = true,
					gitsigns = true,
					treesitter = true,
					notify = true,
					barbar = true,
					diffview = true,
					neotree = true,
					neogit = true,
					noice = true,
					which_key = true,
				},
			})
		end,
	},
}
