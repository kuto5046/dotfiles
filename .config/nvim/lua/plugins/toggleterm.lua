return {
	"akinsho/toggleterm.nvim",
	event = "BufRead",
	config = function()
		require("toggleterm").setup({
			open_mapping = [[<leader>t]],
			insert_mappings = false, -- insert時はmapping適用しない(文字入力時にスペースの入力が遅くなるので)
			direction = "horizontal",
			shade_terminals = false,
		})
	end,
}
