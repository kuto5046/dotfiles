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
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					-- LSP
					"pyright",
					"rust_analyzer",
					"lua_ls",
					-- linter
					"ruff",
				},
			})
			-- reference: https://github.com/neovim/nvim-lspconfig#suggested-configuration
			-- Global mappings.
			-- See `:help vim.diagnostic.*` for documentation on any of the below functions
			vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
			vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
			vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
			-- vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

			-- Use LspAttach autocommand to only map the following keys
			-- after the language server attaches to the current buffer
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					-- Enable completion triggered by <c-x><c-o>
					vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

					-- Buffer local mappings.
					-- See `:help vim.lsp.*` for documentation on any of the below functions
					local opts = { buffer = ev.buf }
					-- vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
					vim.keymap.set("n", "<F12>", vim.lsp.buf.definition, opts)
					-- 定義ジャンプをsplitで開く
					-- vim.keymap.set('n', 'gd<Space>', ':split | lua vim.lsp.buf.definition()<CR>', bufopts)
					-- vim.keymap.set('n', 'gd<CR>', ':vsplit | lua vim.lsp.buf.definition()<CR>', bufopts)
					vim.keymap.set("n", "<F10>", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "<F11>", vim.lsp.buf.implementation, opts)
					-- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
					-- vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
					-- vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
					-- vim.keymap.set('n', '<space>wl', function()
					--   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
					-- end, opts)
					-- vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
					-- vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
					-- vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
					vim.keymap.set("n", "<S-F12>", vim.lsp.buf.references, opts)
					vim.keymap.set("n", "ff", function()
						vim.lsp.buf.format({ async = true })
					end, opts)
				end,
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
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
