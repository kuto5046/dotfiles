return {
	"xiyaowong/transparent.nvim",
	config = function()
		require("transparent").setup({
			extra_groups = {
				"NormalFloat", -- plugins which have float panel such as Lazy, Mason, LspInfo
			},
			-- cursorがある行の背景を透過しない
			exclude_groups = { "CursorLine" },
		})
		-- neo tree関係の背景を透過
		require("transparent").clear_prefix("NeoTree")
		-- lualine関係の背景を透過
		-- require('transparent').clear_prefix('lualine')
		-- icebergを使う時noiceのcommand paletteのfloat windowの背景を透過
		require("transparent").clear_prefix("noice")
		-- buffer関係の背景を透過
		require("transparent").clear_prefix("Buffer")
		-- 常に透過を有効にする
		vim.g.transparent_enabled = true
	end,
}
