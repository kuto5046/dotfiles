return {
	"sindrets/diffview.nvim",
	lazy = false,
	config = function()
		-- Disable vimade in diffview
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "DiffviewFiles", "DiffviewFileHistory" },
			callback = function()
				vim.cmd("VimadeDisable")
			end,
		})
		vim.api.nvim_create_autocmd("User", {
			pattern = "DiffviewViewClosed",
			callback = function()
				vim.cmd("VimadeEnable")
			end,
		})

		-- Auto-preview: select entry on cursor move in file panel
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "DiffviewFiles", "DiffviewFileHistory" },
			callback = function(ev)
				vim.api.nvim_create_autocmd("CursorMoved", {
					buffer = ev.buf,
					callback = function()
						require("diffview").emit("select_entry")
					end,
				})
			end,
		})

		require("diffview").setup({
			keymaps = {
				view = { { "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Close Diffview" } } },
				file_panel = { { "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Close Diffview" } } },
				file_history_panel = { { "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Close Diffview" } } },
			},
		})
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
