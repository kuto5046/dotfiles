local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	PACKER_BOOTSTRAP = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
	print("Installing packer close and reopen Neovim...")
	vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
	return
end

-- Have packer use a popup window
packer.init({
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
})

-- Install your plugins here
return packer.startup(function(use)
	-- My plugins here
	use({ "wbthomason/packer.nvim" })
	use({ "nvim-lua/plenary.nvim" }) -- Common utilities

	-- Colorschemes
	use({ "EdenEast/nightfox.nvim" })

  -- 括弧
  use {
    "windwp/nvim-autopairs",
      config = function() require("nvim-autopairs").setup {} end
  }
  use {
    'andymass/vim-matchup',
    setup = function()
      -- may set any options here
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end
  }

	-- 補完
  use({ "hrsh7th/cmp-nvim-lsp" }) -- lsp 用の補完ソース。
	use({ "hrsh7th/cmp-buffer" }) -- buffer completions
	use({ "hrsh7th/cmp-path" }) -- path completions
	use({ "hrsh7th/cmp-cmdline" }) -- cmdline completions
	use({ "hrsh7th/nvim-cmp" }) -- The completion plugin
	-- use({ "hrsh7th/cmp-nvim-lua" }) -- lua用の補完ソース

 -- snippets (luasnip)
	-- use({ "L3MON4D3/LuaSnip" })
	-- use({ "saadparwaiz1/cmp_luasnip"})

	-- LSP(メジャーな言語のLSPはこれで対応可能)
  use({ "williamboman/mason.nvim" })
  use({ "williamboman/mason-lspconfig.nvim" })
  use({ "neovim/nvim-lspconfig" })

  use({ "jose-elias-alvarez/null-ls.nvim" }) -- for formatters and linters

	-- Telescope
	use({ "nvim-telescope/telescope.nvim" })
  use({ "nvim-telescope/telescope-file-browser.nvim" })
  -- use({
  --   "nvim-telescope/telescope-frecency.nvim",
  --   config = function()
  --     require"telescope".load_extension("frecency")
  --   end,
  --   requires = {"kkharji/sqlite.lua"}
  -- })

	-- Treesitter
  use {
      'nvim-treesitter/nvim-treesitter',
      run = function()
          local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
          ts_update()
      end,
  }

  -- markdown preview
  use({
    "iamcco/markdown-preview.nvim",
    run = function() vim.fn["mkdp#util#install"]() end,
  })
  -- use({ "iamcco/markdown-preview.nvim", run = "cd app && npm install", setup = function() vim.g.mkdp_filetypes = { "markdown" } end, ft = { "markdown" }, })

  -- 見た目
	use {
		'nvim-lualine/lualine.nvim',
		requires = { 'kyazdani42/nvim-web-devicons', opt = true }
	  }
	use({ "kyazdani42/nvim-web-devicons" }) -- File icons
  use {'akinsho/bufferline.nvim', tag = "v3.*", requires = 'nvim-tree/nvim-web-devicons'}
  use({ 'mvllow/modes.nvim', tag = 'v0.2.0' }) -- 行の色でモードが分かる
  use({ "petertriho/nvim-scrollbar"} ) -- スクロールバーを表示
  -- 検索したワードの場所がわかりやすくなる
  -- use {
  --   "kevinhwang91/nvim-hlslens",
  --   config = function()
  --     require("scrollbar.handlers.search").setup({
  --     })
  --   end,
  -- }
  -- gitのsignが出る
  -- use {
  --   "lewis6991/gitsigns.nvim",
  --   config = function()
  --     require('gitsigns').setup()
  --     require("scrollbar.handlers.gitsigns").setup()
  --   end
  -- }

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)
