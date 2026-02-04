return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)
	end,
	opts = {
		-- インストールする言語パーサー
		ensure_installed = {
			"python",
			"lua",
			"vim",
			"vimdoc",
			"rust",
			"go",
			"typescript",
			"tsx",
			"javascript",
			"bash",
			"json",
			"yaml",
			"toml",
			"markdown",
			"markdown_inline",
		},
		-- 自動インストールを有効化
		auto_install = true,
		-- シンタックスハイライトを有効化
		highlight = {
			enable = true,
			-- Vimの正規表現ベースのシンタックスハイライトを無効化（Treesitterを優先）
			additional_vim_regex_highlighting = false,
		},
		-- インデントを有効化
		indent = {
			enable = true,
		},
	},
}
