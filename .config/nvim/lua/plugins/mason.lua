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
					-- LSP
					"pyright",
					"rust_analyzer",
					"lua_ls",
					-- linter
					-- "ruff",
					-- formatter
					-- "stylua",
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

			-- poetryに対応
			require("lspconfig")["pyright"].setup({
				on_atatch = on_attach,
				settings = {
					python = {
						venvPath = ".",
						pythonPath = "./.venv/bin/python",
						analysis = {
							extraPaths = { "." },
						},
					},
				},
			})
		end,
	},
}
