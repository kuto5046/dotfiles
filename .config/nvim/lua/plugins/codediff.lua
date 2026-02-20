return {
	"esmuellert/codediff.nvim",
	dependencies = { "MunifTanjim/nui.nvim" },
	lazy = false,
	config = function()
		require("codediff").setup({
			-- ハイライト設定
			highlights = {
				line_insert = "DiffAdd",
				line_delete = "DiffDelete",
				char_brightness = nil, -- 自動調整
			},
			-- エクスプローラー設定
			explorer = {
				position = "left",
				width = 40,
			},
		})

		-- Keymaps
		vim.keymap.set("n", "<leader>dd", "<cmd>CodeDiff<CR>", {
			noremap = true,
			silent = true,
			desc = "CodeDiff: Git状態を表示",
		})

		vim.keymap.set("n", "<leader>dh", "<cmd>CodeDiff history<CR>", {
			noremap = true,
			silent = true,
			desc = "CodeDiff: コミット履歴",
		})

		vim.keymap.set("n", "<leader>dp", function()
			local branch = vim.fn.system("git rev-parse --abbrev-ref HEAD"):gsub("%s+", "")
			local reflog = vim.fn.systemlist("git reflog show --format=%H " .. branch)
			local fork_point = reflog[#reflog]
			if not fork_point or fork_point == "" then
				vim.notify("Could not determine branch fork point", vim.log.levels.ERROR)
				return
			end
			vim.cmd("CodeDiff " .. fork_point .. "...")
		end, {
			noremap = true,
			silent = true,
			desc = "CodeDiff: PR diff (from branch fork point)",
		})

		vim.keymap.set("n", "<leader>df", "<cmd>CodeDiff file HEAD<CR>", {
			noremap = true,
			silent = true,
			desc = "CodeDiff: 現在のファイルとHEADを比較",
		})
	end,
}
