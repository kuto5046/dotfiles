return {
	"max397574/better-escape.nvim",
	event = { "InsertEnter", "CmdlineEnter", "TermOpen" },
	opts = {
		timeout = 100,
		default_mappings = false,
		mappings = {
			i = { j = { k = "<ESC>" } },
			c = { j = { k = "<ESC>" } },
			t = {
				j = { k = "<C-\\><C-n>" },
			},
		},
	},
}
