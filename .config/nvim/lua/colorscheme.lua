if not vim.g.vscode then
	vim.cmd("colorscheme nightfox")
	-- vim.cmd("colorscheme iceberg")
	-- vim.cmd("colorscheme catppuccin-mocha") --catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha
end

-- 背景を透過可能にする(for iceberg)
-- highlight設定可能な種別: https://vim-jp.org/vimdoc-ja/syntax.html
-- vim/neovimの対応表: https://zenn.dev/leviosa42/scraps/afe31f249fd1b2
-- vim.cmd[[highlight Normal guibg=NONE ctermbg=NONE]]
-- vim.cmd[[highlight NonText guibg=NONE ctermbg=NONE]]  -- 特殊な文字
-- vim.cmd[[highlight LineNr guibg=NONE ctermbg=NONE]]  -- 行番号
vim.cmd([[highlight Folded guibg=NONE ctermbg=NONE]]) -- 折りたたみ
-- vim.cmd[[highlight EndOfBuffer guibg=NONE ctermbg=NONE]]  -- ~で埋められている空白部分
-- vim.cmd[[highlight VertSplit guibg=NONE ctermbg=NONE]]  -- windowの境界線
-- git signs(反映されたように思えたが反映されていない？)
-- vim.cmd[[highlight GitSignsAdd guibg=NONE]]
-- vim.cmd[[highlight GitSignsChange guibg=NONE]]
-- vim.cmd[[highlight GitSignsDelete guibg=NONE]]
-- popup(PMenu以外はあまり意味ない)
-- vim.cmd[[highlight Pmenu guibg=NONE ctermbg=NONE]]
-- vim.cmd[[highlight PmenuSel guibg=NONE ctermbg=NONE]]
-- vim.cmd[[highlight PmenuSbar guibg=NONE ctermbg=NONE]]
-- vim.cmd[[highlight Normalfloat guibg=NONE ctermbg=NONE]]

-- TODO: 透過がうまくいかない個所
-- icebergのみ
-- cmdlineのpopupの境界
-- noiceのerrorの文字の背景
-- statusline
-- fidgetの背景
