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
		vim.keymap.set("n", "<leader>vp", function()
			local base = vim.fn.system("git merge-base HEAD main 2>/dev/null || git merge-base HEAD master"):gsub("%s+", "")
			if base == "" then
				vim.notify("Could not determine base branch", vim.log.levels.ERROR)
				return
			end
			vim.cmd("DiffviewOpen " .. base .. "..HEAD")
		end, { noremap = true, silent = true, desc = "Diffview PR diff (vs main)" })
	end,
}
