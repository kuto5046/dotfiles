return {
	{ "EdenEast/nightfox.nvim" },
	{ "cocopon/iceberg.vim" },
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			-- TODO: dockerコンテナで利用するとなぜか背景色が一部強調されてしまう
			require("catppuccin").setup({
				-- transparent_background = true,
				-- italicが強調されてhighlightされるので、無効にする
				no_italic = true,
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
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
	},
	{
		"rose-pine/neovim",
		-- name = "rose-pine",
		config = function()
			require("rose-pine").setup({
				styles = {
					italic = false,
				},
			})
		end,
	},
	{
		"rebelot/kanagawa.nvim",
		config = function()
			require("kanagawa").setup({
				compile = false,
				undercurl = true,
				commentStyle = { italic = false },
				functionStyle = {},
				keywordStyle = { italic = false },
				statementStyle = { bold = true },
				typeStyle = {},
				transparent = false,
				dimInactive = false,
				terminalColors = true,
				colors = {
					palette = {},
					theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
				},
			})
		end,
	},
}
