return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "kyazdani42/nvim-web-devicons", lazy = true },
	event = { "BufNewFile", "BufRead" },
	config = 'require("lualine").setup()',
}
