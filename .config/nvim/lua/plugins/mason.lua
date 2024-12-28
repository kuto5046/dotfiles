return {
	{
		"williamboman/mason.nvim",
		-- これらのコマンドが実行された時に読み込みを行う
		cmd = {
			"Mason",
			"MasonInstall",
			"MasonUninstall",
			"MasonUninstallAll",
			"MasonLog",
			"MasonUpdate",
		},
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		event = { "BufNewFile", "BufRead" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"rust_analyzer",
					"lua_ls",
					-- 仮想環境のライブラリを使用するため、pyrightとruffはコメントアウト
					"pyright",
					"ruff",
				},
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		event = { "BufNewFile", "BufRead" },
		config = function()
			-- After setting up mason-lspconfig you may set up servers via lspconfig
			require("lspconfig")["lua_ls"].setup({})
			require("lspconfig")["rust_analyzer"].setup({})
			require("lspconfig")["pyright"].setup({
				settings = {
					pyright = {
						-- importはruff側で管理する(機能していない)
						disableOrganizeImports = true,
					},
					python = {
						-- venv-selector側で仮想環境を有効化するため、コメントアウト
						-- venvPath = ".",
						-- pythonPath = "./.venv/bin/python",
						-- 機能していない
						analysis = {
							-- Ignore all files for analysis to exclusively use Ruff for linting
							ignore = { "*" },
						},
					},
				},
			})
			require("lspconfig")["ruff"].setup({})
		end,
	},
}
