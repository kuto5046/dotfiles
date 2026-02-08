return {
	"coder/claudecode.nvim",
	enabled = true,
	dependencies = { "folke/snacks.nvim" },
	config = true,
	opts = {
		terminal = {
			provider = "none", -- sidekickに任せる
		},
		-- IDE統合機能を有効化
		git_repo_cwd = true, -- gitリポジトリのルートを自動検出
		track_selection = true, -- 選択範囲を自動追跡
		auto_attach = true, -- 既存のClaude Codeセッションに自動接続
	}
}
