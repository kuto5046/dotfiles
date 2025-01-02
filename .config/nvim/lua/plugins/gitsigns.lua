return {
	-- Adds git releated signs to the gutter, as well as utilities for managing changes
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("gitsigns").setup({
			-- See `:help gitsigns.txt`
			current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
		})
	end,
}
