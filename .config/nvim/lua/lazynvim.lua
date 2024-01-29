-- install lazy.nvim if not exists
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
local opts = {
	defaults = {
		lazy = false,
	},
	performance = {
		cache = {
			enabled = true,
		},
	},
}

if not vim.g.vscode then
	-- Any lua file in ~/.config/nvim/lua/plugins/*.lua will be automatically merged in the main plugin spec
	require("lazy").setup("plugins", opts)
end
