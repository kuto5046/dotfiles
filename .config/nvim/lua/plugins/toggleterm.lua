return {
	"akinsho/toggleterm.nvim",
	event = "BufRead",
	config = function()
		require("toggleterm").setup({
			open_mapping = [[<C-t>]],
			start_in_insert = true,
			insert_mappings = false, -- insert時はmapping適用しない(文字入力時にスペースの入力が遅くなるので)
			direction = "float",
			shade_terminals = false,
		})
	end,
}
