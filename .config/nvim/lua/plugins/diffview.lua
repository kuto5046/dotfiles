return {
	"sindrets/diffview.nvim",
	event = "BufRead",
	config = function()
		-- Keymaps
		vim.keymap.set(
			"n",
			"<leader>dd",
			"<cmd>DiffviewOpen <CR>",
			{ noremap = true, silent = true, desc = "Diffview" }
		)
		vim.keymap.set(
			"n",
			"<leader>dh",
			"<cmd>DiffviewFileHistory %<CR>",
			{ noremap = true, silent = true, desc = "Diffview file history" }
		)
		vim.keymap.set("n", "<leader>dp", function()
			local branch = vim.fn.system("git rev-parse --abbrev-ref HEAD"):gsub("%s+", "")
			local reflog = vim.fn.systemlist("git reflog show --format=%H " .. branch)
			local fork_point = reflog[#reflog]
			if not fork_point or fork_point == "" then
				vim.notify("Could not determine branch fork point", vim.log.levels.ERROR)
				return
			end
			vim.cmd("DiffviewOpen " .. fork_point .. "..HEAD")
		end, { noremap = true, silent = true, desc = "Diffview PR diff (from branch fork point)" })
	end,
}
