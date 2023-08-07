require("toggleterm").setup({
	open_mapping = [[<leader>t]],
	insert_mappings = false, -- insert時はmapping適用しない(文字入力時にスペースの入力が遅くなるので)
	direction = "float",
	highlights = {
		FloatBorder = { guifg = "#719cd6" },
	},
	float_opts = {
		border = "curved",
		height = 20,
	},
})
