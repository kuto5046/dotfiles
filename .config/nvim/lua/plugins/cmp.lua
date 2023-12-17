-- Set up nvim-cmp.
return {
	-- 補完(LSPだけだと候補が出ない)
	{
		"hrsh7th/cmp-nvim-lsp",
		config = function()
			local cmp = require("cmp")
			-- local has_words_before = function()
			-- 	if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
			-- 	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
			-- 	return col ~= 0 and vim.api.nvim_buf_get_text(0, line-1, 0, line-1, col, {})[1]:match("^%s*$") == nil
			--   end
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
				-- mapping = {
				-- 	["<Tab>"] = vim.schedule_wrap(function(fallback)
				-- 	  if cmp.visible() and has_words_before() then
				-- 		cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
				-- 	  else
				-- 		fallback()
				-- 	  end
				-- 	end),
				--   },
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
	{ "hrsh7th/cmp-buffer" }, -- buffer completions
	{ "hrsh7th/cmp-path" }, -- path completions
	{ "hrsh7th/cmp-cmdline" }, -- cmdline completions
	{ "hrsh7th/nvim-cmp" }, -- The completion plugin
	{ "hrsh7th/cmp-nvim-lua" }, -- lua completions
	{ "hrsh7th/vim-vsnip" }, -- vsnip snippets
	{ "hrsh7th/cmp-vsnip" }, -- vsnip completions
	{
		"onsails/lspkind-nvim",
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
