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
  use({ "nvim-lua/popup.nvim" })

	-- Colorschemes
	use({ "EdenEast/nightfox.nvim" })
  use({ "catppuccin/nvim", as = "catppuccin" })
  use({ "cocopon/iceberg.vim" })

  -- 括弧
  use ({
    "windwp/nvim-autopairs",
      config = function() require("nvim-autopairs").setup {} end
  })
  use ({
    'andymass/vim-matchup',
    setup = function()
      -- may set any options here
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end
  })


	-- LSP(メジャーな言語のLSPはこれで対応可能)
  use({ "williamboman/mason.nvim" })
  use({ "williamboman/mason-lspconfig.nvim" })
  use({ "neovim/nvim-lspconfig" })

	-- 補完(LSPだけだと候補が出ない)
  use({ "hrsh7th/cmp-nvim-lsp" }) -- lsp completions
	use({ "hrsh7th/cmp-buffer" }) -- buffer completions
	use({ "hrsh7th/cmp-path" }) -- path completions
	use({ "hrsh7th/cmp-cmdline" }) -- cmdline completions
	use({ "hrsh7th/nvim-cmp" }) -- The completion plugin
	use({ "hrsh7th/cmp-nvim-lua" }) -- lua completions
  use({ "github/copilot.vim" })  -- copilot
  use({ "hrsh7th/vim-vsnip" }) -- vsnip snippets
  use({ "hrsh7th/cmp-vsnip" }) -- vsnip completions
  use({ "onsails/lspkind-nvim" }) -- pictograms for lsp completion items

  -- formatter/liner
  use({ "jose-elias-alvarez/null-ls.nvim" }) -- for formatters and linters

  -- Telescope
  use({ "nvim-telescope/telescope.nvim", tag='0.1.1' })
  use({ "nvim-telescope/telescope-file-browser.nvim" })
  use({ "nvim-telescope/telescope-media-files.nvim" })
  use({
    "nvim-telescope/telescope-frecency.nvim",
    config = function()
      require"telescope".load_extension("frecency")
    end,
    requires = {"kkharji/sqlite.lua"}
  })
  use({ "nvim-tree/nvim-tree.lua" })

	-- Treesitter
  use ({
      'nvim-treesitter/nvim-treesitter',
      run = function()
          local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
          ts_update()
      end,
  })

  -- git
  use ({ 'NeogitOrg/neogit', requires = 'nvim-lua/plenary.nvim' })
  use ({ 'sindrets/diffview.nvim', requires = 'nvim-lua/plenary.nvim', after='plenary.nvim' })

  -- 見た目
	use ({'nvim-lualine/lualine.nvim', requires = { 'nvim-tree/nvim-web-devicons', opt = true }})
	use({ "nvim-tree/nvim-web-devicons" }) -- File icons
  -- use { "akinsho/bufferline.nvim", tag = "v3.*", requires = 'nvim-tree/nvim-web-devicons'}
  use({ "mvllow/modes.nvim", tag = 'v0.2.0' }) -- 行の色でモードが分かる
  use({ "j-hui/fidget.nvim", tag='legacy' }) -- LSP progress UI
  use({ "petertriho/nvim-scrollbar"} ) -- スクロールバーを表示
  -- 検索したワードの場所がわかりやすくなる
  use({ "kevinhwang91/nvim-hlslens" })
  -- gitのsignが出る
  use {
    "lewis6991/gitsigns.nvim",
    config = function()
      require('gitsigns').setup()
      require("scrollbar.handlers.gitsigns").setup()
    end
  }
  use( { "romgrk/barbar.nvim" })  --tabline(tabの見た目を変える)

  --  other
  -- markdown preview
  use({
    "iamcco/markdown-preview.nvim",
    run = function() vim.fn["mkdp#util#install"]() end,
  })

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)

