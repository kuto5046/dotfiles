local wezterm = require("wezterm")

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- color schemeの設定
config.color_scheme = "nightfox"

-- 背景透過
config.window_background_opacity = 0.85

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
config.font_size = 12

-- IMEで日本語入力を有効化
config.use_ime = true

-- デフォルトのキーバインドを無効化
-- config.disable_default_key_bindings = true

return config
