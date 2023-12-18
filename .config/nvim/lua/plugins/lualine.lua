return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = { "BufNewFile", "BufRead" },
	config = 'require("lualine").setup()',
}
