-- -- vscodeで利用すると黒い点が表示されるので、vscodeの場合は読み込まない
if vim.g.vscode then
	return {}
else
	return {
		"petertriho/nvim-scrollbar",
		event = "BufRead",
		config = function()
			require("scrollbar").setup()
		end,
	}
end
