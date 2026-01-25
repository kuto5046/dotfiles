return {
	{ "nvim-telescope/telescope.nvim", version = "v0.2.0", dependencies = { "nvim-lua/plenary.nvim" } },
	{ "nvim-telescope/telescope-file-browser.nvim" },
	{ "nvim-telescope/telescope-frecency.nvim", dependencies = { "kkharji/sqlite.lua" } },
	config = function()
		-- TODO: initial modeがinsertになってしまう
		require("telescope").setup({
			defaults = {
				winblend = 0, -- 1にするだけで透過になる調整できないか？
				initial_mode = "normal",
			},
			pickers = {
				find_files = {
					hidden = true,
				},
			},
		})
		-- telescope file browser
		require("telescope").load_extension("file_browser")
		-- telescope frecency
		require("telescope").load_extension("frecency")

		-- Keymaps
		local builtin = require("telescope.builtin")

		-- find系
		vim.keymap.set("n", "<leader>f", builtin.find_files, { desc = "Find files" })
		vim.keymap.set("n", "<leader>gg", builtin.live_grep, { desc = "Live grep" })
		vim.keymap.set("n", "<leader>e", builtin.diagnostics, { desc = "Diagnostics" })
		vim.keymap.set("n", "<leader>h", builtin.help_tags, { desc = "Help tags" })
		vim.keymap.set("n", "<leader>k", builtin.keymaps, { desc = "Keymaps" })

		-- git系
		vim.keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "Git commits" })
		vim.keymap.set("n", "<leader>gb", builtin.git_branches, { desc = "Git branches" })
		vim.keymap.set("n", "<leader>gs", builtin.git_status, { desc = "Git status" })

		-- notify
		vim.keymap.set("n", "<leader>n", function()
			require("telescope").extensions.notify.notify({
				initial_mode = "normal",
			})
		end, { desc = "Notify" })

		-- browser
		vim.keymap.set("n", "<leader>b", function()
			require("telescope").extensions.file_browser.file_browser({
				path = "%:p:h",
				respect_gitignore = false,
				hidden = true,
				grouped = true,
				initial_mode = "normal",
			})
		end, { desc = "File browser" })

		-- frecency
		vim.keymap.set(
			"n",
			"<leader>r",
			"<Cmd>lua require('telescope').extensions.frecency.frecency()<CR>",
			{ noremap = true, silent = true, desc = "Telescope Frecency" }
		)
	end,
}
