if vim.g.vscode then
	return {}
else
	return {

		"nvim-neo-tree/neo-tree.nvim",
		enabled = false,
		-- 起動時にtreeを開きたいのでVimEnter
		event = { "VimEnter" },
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
			-- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
		},
		config = function()
			-- グローバルなキーマッピングを設定（どこからでもtoggleできる）
			vim.keymap.set(
				"n",
				"<leader>b",
				":Neotree toggle<CR>",
				{ desc = "toggle neo-tree", noremap = true, silent = true }
			)

			require("neo-tree").setup({
				enable_git_status = true,
				enable_diagnostics = false,
				window = {
					mappings = {
						["<leader>b"] = "close_window",
					},
				},
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
