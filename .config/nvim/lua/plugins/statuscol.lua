return {
	"luukvbaal/statuscol.nvim",
	config = function()
		local builtin = require("statuscol.builtin")
		require("statuscol").setup({
			-- configuration goes here, for example:
			-- relculright = true,
			segments = {
				-- line number(番号をclickするとcursorが遷移する)
				{ text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
				-- git status
				{ sign = { namespace = { "gitsigns" }, maxwidth = 1, colwidth = 1 } },
				-- fold
				{ text = { builtin.foldfunc, " " }, click = "v:lua.ScFa" },
			},
		})
	end,
}
