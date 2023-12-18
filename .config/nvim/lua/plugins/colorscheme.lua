return {
	{
		"EdenEast/nightfox.nvim",
		config = function()
			require("nightfox").setup({
				options = {
					-- 透明度の設定(trueにすると透明にできるがfidgetの表示が目立つようになるのが気になる)
					transparent = false,
				},
			})
		end,
	},
	{
		"cocopon/iceberg.vim",
	},
}
