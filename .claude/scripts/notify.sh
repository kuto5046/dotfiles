#!/bin/bash
# Claude Code 通知スクリプト
# 環境に応じて適切な音声通知を実行します

# OSを判定
OS="$(uname -s)"

case "$OS" in
    Darwin)
        # macOS
        if command -v afplay &> /dev/null; then
            afplay /System/Library/Sounds/Glass.aiff &
        else
            echo "afplay command not found" >&2
            exit 1
        fi
        ;;

    Linux)
        # Linux環境での音声再生
        # PulseAudio (paplay) を優先的に試す
        if command -v paplay &> /dev/null; then
            # 一般的な音声ファイルのパスを順に試す
            SOUND_PATHS=(
                "/usr/share/sounds/freedesktop/stereo/complete.oga"
                "/usr/share/sounds/freedesktop/stereo/bell.oga"
                "/usr/share/sounds/ubuntu/stereo/message.ogg"
                "/usr/share/sounds/gnome/default/alerts/glass.ogg"
                "/usr/share/sounds/sound-icons/glass-water-1.wav"
            )

            for sound in "${SOUND_PATHS[@]}"; do
                if [ -f "$sound" ]; then
                    paplay "$sound" &
                    exit 0
                fi
            done

            echo "No suitable sound file found for paplay" >&2
            exit 1

        # ALSA (aplay) をフォールバック
        elif command -v aplay &> /dev/null; then
            SOUND_PATHS=(
                "/usr/share/sounds/alsa/Front_Center.wav"
                "/usr/share/sounds/sound-icons/glass-water-1.wav"
                "/usr/share/sounds/freedesktop/stereo/complete.oga"
            )

            for sound in "${SOUND_PATHS[@]}"; do
                if [ -f "$sound" ]; then
                    aplay "$sound" &> /dev/null &
                    exit 0
                fi
            done

            echo "No suitable sound file found for aplay" >&2
            exit 1

        # beep コマンドをフォールバック（ターミナルビープ音）
        elif command -v beep &> /dev/null; then
            beep -f 800 -l 200 &

        # 最終手段としてシステムビープ
        else
            echo -e "\a"
        fi
        ;;

    *)
        # その他のOS（CYGWIN, MINGWなど）
        echo "Unsupported OS: $OS" >&2
        echo -e "\a"
        exit 1
        ;;
esac

exit 0
