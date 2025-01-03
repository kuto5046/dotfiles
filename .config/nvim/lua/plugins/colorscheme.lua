return {
	{ "EdenEast/nightfox.nvim" },
	{ "cocopon/iceberg.vim" },
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			-- tODO: dockerコンテナで利用するとなぜか背景色が一部強調されてしまう
			require("catppuccin").setup({
				transparent_background = true,
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
