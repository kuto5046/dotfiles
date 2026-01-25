return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
		bigfile = { enabled = true },
		dashboard = { enabled = true },
		explorer = { enabled = true },
		indent = { enabled = true },
		input = { enabled = true },
		picker = { enabled = true },
		notifier = { enabled = true },
		quickfile = { enabled = true },
		scope = { enabled = true },
		scroll = { enabled = true },
		statuscolumn = { enabled = true },
		words = { enabled = true },
		lazygit = {
			-- your lazygit configuration comes here
			-- or leave it empty to use the default settings
		},
	},
	keys = {
		{
			"<leader>gl",
			mode = "n",
			noremap = true,
			desc = "Git: Open Lazygit",
			function()
				_G.__snacks_last_lg = require("snacks").lazygit.open()
				_G._SNACKS_LG_CLOSE = function()
					local last_lg = _G.__snacks_last_lg
					if last_lg and last_lg.close then
						pcall(last_lg.close, last_lg)
					end
					_G.__snacks_last_lg = nil
				end
			end,
		},
	},
}
