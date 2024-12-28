-- venv-selectorで仮想環境を選択するためにpythonのLSP(pyright)を有効にしておかないといけないのでmason側で設定する
-- 仮想環境を選択した時点で仮想環境のpyrightやruffが有効になる想定
return {
	"linux-cultist/venv-selector.nvim",
	-- dependencies = {
	--   "neovim/nvim-lspconfig",
	--   -- "mfussenegger/nvim-dap",
	--   -- "mfussenegger/nvim-dap-python", --optional
	-- },
	event = "BufReadPre",
	branch = "regexp", -- This is the regexp branch, use this for the new version
	opts = {
		settings = {
			options = {
				activate_venv_in_terminal = true,
				cached_venv_automatic_activation = true,
				debug = true,
				enable_cached_venvs = true,
				notify_user_on_venv_activation = true,
			},
		},
	},
	keys = {
		{ "<leader>v", "<cmd>VenvSelect<cr>" },
	},
}
