local wezterm = require("wezterm")

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- color schemeの設定
config.color_scheme = "nightfox"

-- 背景透過
config.window_background_opacity = 0.7

-- 背景をぼかす
config.macos_window_background_blur = 30

-- title barを非表示
config.window_decorations = "RESIZE"

-- フォントの設定
config.font = wezterm.font_with_fallback({
	"JetBrains Mono",
	"Menlo",
	"DroidSansMono Nerd Font Mono",
})
-- フォントサイズの設定
config.font_size = 13

-- IMEで日本語入力を有効化
config.use_ime = true

-- デフォルトのキーバインドを無効化
-- config.disable_default_key_bindings = true
config.keys = {
	-- cmd+t を無効化（何も実行しない）
	{
		key = "t",
		mods = "CMD",
		action = wezterm.action.DisableDefaultAssignment,
	},
}

return config
