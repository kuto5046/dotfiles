return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").install({ "python", "go", "rust", "typescript", "markdown", "lua" })
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "python", "go", "rust", "typescript", "markdown", "lua" },
			callback = function()
				vim.treesitter.start()
			end,
		})
	end,
}
