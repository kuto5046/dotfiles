return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = { "BufNewFile", "BufRead" },
	config = function()
		require("lualine").setup({
			sections = {
				lualine_x = {
					"encoding",
					"fileformat",
					"filetype",
					-- copilot status
					{
						function()
							return require("copilot_status").status_string()
						end,
						cnd = function()
							return require("copilot_status").enabled()
						end,
					},
				},
			},
		})
	end,
}
