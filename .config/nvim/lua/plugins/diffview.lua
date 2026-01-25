return {
	"sindrets/diffview.nvim",
	event = "BufRead",
	config = function()
		-- Keymaps
		vim.keymap.set(
			"n",
			"<leader>vd",
			"<cmd>DiffviewOpen <CR>",
			{ noremap = true, silent = true, desc = "Diffview" }
		)
		vim.keymap.set(
			"n",
			"<leader>vh",
			"<cmd>DiffviewFileHistory %<CR>",
			{ noremap = true, silent = true, desc = "Diffview file history" }
		)
	end,
}
