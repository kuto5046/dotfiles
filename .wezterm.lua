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

-- 最初からフルスクリーンで起動
-- local mux = wezterm.mux
-- wezterm.on("gui-startup", function(cmd)
-- 	local tab, pane, window = mux.spawn_window(cmd or {})
-- 	window:gui_window():toggle_fullscreen()
-- end)

-- フォントの設定
config.font = wezterm.font_with_fallback({
	"JetBrains Mono",
	"Menlo",
	"DroidSansMono Nerd Font Mono",
})
-- フォントサイズの設定
config.font_size = 13

-- ssh時の設定
config.ssh_domains = {
	{
		-- This name identifies the domain
		name = "kubuntu",
		-- The hostname or address to connect to. Will be used to match settings
		-- from your ssh config file
		remote_address = "100.124.177.19:50022",
		-- The username to use on the remote host
		username = "kuto",
	},
}

return config
