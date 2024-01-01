return {
	"j-hui/fidget.nvim",
	event = { "BufNewFile", "BufRead" },
	-- なぜか効かず背景が透明にならない
	-- config = function()
	-- 	require("fidget").setup({
	-- 		notifications = {
	-- 			-- 透過度の設定
	-- 			window = {
	-- 				winblend = 100,
	-- 			},
	-- 		},
	-- 	})
	-- end,
}
