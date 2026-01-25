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
			-- After setting up mason-lspconfig you may set up servers via vim.lsp.config
			vim.lsp.config["lua_ls"] = {}
			vim.lsp.enable("lua_ls")

			vim.lsp.config["rust_analyzer"] = {}
			vim.lsp.enable("rust_analyzer")

			vim.lsp.config["pyright"] = {
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
			}
			vim.lsp.enable("pyright")

			vim.lsp.config["ruff"] = {}
			vim.lsp.enable("ruff")

			-- LSP Keymaps
			-- Use LspAttach autocommand to only map the following keys
			-- after the language server attaches to the current buffer
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					-- Enable completion triggered by <c-x><c-o>
					vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

					-- overlookでピーク表示（ポップアップ内でジャンプも可能）
					vim.keymap.set("n", "gd", function()
						require("overlook.api").peek_definition()
					end, { buffer = ev.buf, desc = "Peek definition" })

					vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = ev.buf, desc = "Show hover" })
					vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = ev.buf, desc = "Go to references" })
					vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, { buffer = ev.buf, desc = "Rename" })
					vim.keymap.set("n", "ff", function()
						vim.lsp.buf.format({ async = true })
					end, { buffer = ev.buf, desc = "Format" })
				end,
			})
		end,
	},
}
