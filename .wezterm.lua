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
config.macos_window_background_blur = 50

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

-- キーバインディングの設定
config.keys = {
	{
		key = "t",
		mods = "CMD|CTRL",
		action = wezterm.action_callback(function(window, pane)
			local overrides = window:get_config_overrides() or {}
			if not overrides.window_background_opacity then
				-- 透明度を上げて、ぼかしをゼロにする
				overrides.window_background_opacity = 0.7
				overrides.macos_window_background_blur = 0
			else
				-- 元の設定に戻す
				overrides.window_background_opacity = nil
				overrides.macos_window_background_blur = nil
			end
			window:set_config_overrides(overrides)
		end),
	},
}

return config
