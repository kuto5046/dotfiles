return {
	"akinsho/toggleterm.nvim",
	event = "BufRead",
	config = function()
		require("toggleterm").setup({
			open_mapping = [[<C-t>]],
			start_in_insert = true,
			insert_mappings = false, -- insert時はmapping適用しない(文字入力時にスペースの入力が遅くなるので)
			direction = "horizontal",
			size = 20, -- ターミナルの高さ(行数)
			shade_terminalts = false,
		})
	end,
}
