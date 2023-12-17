local options = {
	encoding = "utf-8",
	fileencoding = "utf-8",
	title = true,
	backup = false,
	clipboard = "unnamedplus",
	cmdheight = 2,
	completeopt = { "menuone", "noselect" },
	conceallevel = 0,
	hlsearch = true,
	ignorecase = true,
	mouse = "a",
	pumheight = 10,
	showmode = false,
	showtabline = 2,
	smartcase = true,
	smartindent = true,
	swapfile = false,
	timeoutlen = 300,
	undofile = true,
	updatetime = 300,
	writebackup = false,
	shell = "zsh",
	backupskip = { "/tmp/*", "/private/tmp/*" },
	expandtab = true,
	shiftwidth = 2,
	tabstop = 2,
	cursorline = false,
	number = true,
	relativenumber = false,
	numberwidth = 4,
	signcolumn = "yes",
	wrap = false,
	-- winblend = 0,  -- ウィンドウの透明度だがターミナルの透明度に依存する
	wildoptions = "pum",
	pumblend = 10,
	background = "dark",
	scrolloff = 8,
	sidescrolloff = 8,
	guifont = "monospace:h17",
	splitbelow = true, -- オンのとき、ウィンドウを横分割すると新しいウィンドウはカレントウィンドウの下に開かれる
	splitright = true, -- オンのとき、ウィンドウを縦分割すると新しいウィンドウはカレントウィンドウの右に開かれる
	termguicolors = true,
	laststatus = 3,
}

vim.scriptencoding = "utf-8"
vim.wo.number = true
vim.opt.shortmess:append("c")
vim.g.mkdp_theme = "light" -- markdownの色

for k, v in pairs(options) do
	vim.opt[k] = v
end

vim.cmd("set whichwrap+=<,>,[,],h,l")
vim.cmd([[set iskeyword+=-]])
vim.cmd([[set formatoptions-=cro]]) -- TODO: this doesn't seem to work
-- vim.api.nvim_create_user_command("T split | wincmd j | resize 20 | terminal ")

-- clipboard settings for ssh
if vim.env.TMUX then
	vim.g.clipboard = {
		name = "tmux",
		copy = {
			["+"] = { "tmux", "load-buffer", "-w", "-" },
			["*"] = { "tmux", "load-buffer", "-w", "-" },
		},
		paste = {
			["+"] = { "bash", "-c", "tmux refresh-client -l && sleep 0.2 && tmux save-buffer -" },
			["*"] = { "bash", "-c", "tmux refresh-client -l && sleep 0.2 && tmux save-buffer -" },
		},
		cache_enabled = false,
	}
end
