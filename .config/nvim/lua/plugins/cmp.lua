-- Set up nvim-cmp.
return {
	-- 補完(LSPだけだと候補が出ない)
	{
		"hrsh7th/cmp-nvim-lsp",
		event = "InsertEnter",
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				snippet = {
					expand = function(args)
						vim.fn["vsnip#anonymous"](args.body)
					end,
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
				}),
				sources = cmp.config.sources({
					-- Copilot Source
					{ name = "copilot" },
					{ name = "nvim_lsp" },
					{ name = "vsnip" },
				}, {
					{ name = "buffer" },
				}),
			})

			-- Set configuration for specific filetype.
			cmp.setup.filetype("gitcommit", {
				sources = cmp.config.sources({
					{ name = "cmp_git" }, -- You can specify the `cmp_git` source if you were installed it.
				}, {
					{ name = "buffer" },
				}),
			})

			-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
			})
		end,
	}, -- lsp completions
	{ "hrsh7th/cmp-buffer", event = "InsertEnter" }, -- buffer completions
	{ "hrsh7th/cmp-path", event = "InsertEnter" }, -- path completions
	{ "hrsh7th/cmp-cmdline", event = "InsertEnter" }, -- cmdline completions
	{ "hrsh7th/nvim-cmp", event = "InsertEnter" }, -- The completion plugin
	{ "hrsh7th/cmp-nvim-lua", event = "InsertEnter" }, -- lua completions
	{ "hrsh7th/vim-vsnip", event = "InsertEnter" }, -- vsnip snippets
	{ "hrsh7th/cmp-vsnip", event = "InsertEnter" }, -- vsnip completions
	{
		"onsails/lspkind-nvim",
		event = "InsertEnter",
		config = function()
			-- Set up lspkind.
			local cmp = require("cmp")
			local lspkind = require("lspkind")

			-- for copilot
			lspkind.init({
				symbol_map = {
					Copilot = "",
				},
			})
			vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })

			cmp.setup({
				formatting = {
					format = lspkind.cmp_format({
						mode = "symbol_text",
						maxwidth = 50,
						ellipsis_char = "...",
						before = function(entry, vim_item)
							return vim_item
						end,
					}),
				},
			})
		end,
	}, -- pictograms for lsp completion items
}
