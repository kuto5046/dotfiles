return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = { "BufNewFile", "BufRead" },
	config = function()
		local lsp_names = function()
			local clients = {}
			for _, client in ipairs(vim.lsp.get_active_clients({ bufnr = 0 })) do
				if client.name == "null-ls" then
					local sources = {}
					for _, source in ipairs(require("null-ls.sources").get_available(vim.bo.filetype)) do
						table.insert(sources, source.name)
					end
					table.insert(clients, "null-ls(" .. table.concat(sources, ", ") .. ")")
				else
					table.insert(clients, client.name)
				end
			end
			return " " .. table.concat(clients, ", ")
		end

		require("lualine").setup({
			sections = {
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_x = {
					lsp_names,
				},
				lualine_y = {
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
