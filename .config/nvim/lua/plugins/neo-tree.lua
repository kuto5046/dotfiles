if vim.g.vscode then
	return {}
else
	return {

		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
			-- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
		},
		keys = {
			{ "<C-b>", ":Neotree toggle<Return>", desc = "toggle neo-tree" },
		},
		config = function()
			require("neo-tree").setup({
				enable_git_status = true,
				enable_diagnostics = false,
				filesystem = {
					filtered_items = {
						hide_dotfiles = false,
						hide_gitignored = false,
					},
				},
				default_component_configs = {
					git_status = {
						symbols = {
							-- Change type
							added = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
							modified = "", -- or "", but this is redundant info if you use git_status_colors on the name
							deleted = "✖", -- this can only be used in the git_status source
							renamed = "󰁕", -- this can only be used in the git_status source
							-- Status type
							untracked = "U",
							ignored = "",
							unstaged = "",
							staged = "",
							conflict = "",
						},
					},
				},
			})
		end,
	}
end
