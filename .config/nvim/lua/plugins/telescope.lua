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
	end,
}
