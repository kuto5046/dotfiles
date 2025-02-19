local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

-- Remove whitespace on save
autocmd("BufWritePre", {
	pattern = "*",
	command = ":%s/\\s\\+$//e",
})

-- Don't auto commenting new lines
autocmd("BufEnter", {
	pattern = "*",
	command = "set fo-=c fo-=r fo-=o",
})

-- Restore cursor location when file is opened
autocmd({ "BufReadPost" }, {
	pattern = { "*" },
	callback = function()
		vim.api.nvim_exec('silent! normal! g`"zv', false)
	end,
})

-- ターミナルは常にinsertモード
autocmd("TermOpen", {
	pattern = "*",
	command = ":startinsert",
})

-- ターミナル上では行番号を表示しない
autocmd("TermOpen", {
	pattern = "*",
	command = "setlocal norelativenumber",
})
autocmd("TermOpen", {
	pattern = "*",
	command = "setlocal nonumber",
})

-- 自動保存
-- vim.cmd([[
--   augroup autosave
--     autocmd!
--     autocmd TextChanged,TextChangedI <buffer> silent write
--   augroup END
-- ]])
