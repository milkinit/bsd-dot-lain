#!/bin/sh
set -euo pipefail

DOAS=""
if [[ "$(id -u)" -ne 0 ]]; then DOAS="doas"; fi

copy_config() {
        local src=".config"
        local dst="$HOME/"

        if [[ ! -e "$src" ]]; then
                echo "Config source not found: $src"
                exit 1
        fi

        echo "| COPYING CONFIG FILES |"
        mkdir -p "$dst"
        cp -rf "$src" "$dst"
        echo "| DONE |"
}

update_system() {
        echo "| UPDATING SYSTEM |"
        $DOAS pkg upgrade
        echo "| DONE |"
}


install_deps() {
        echo "| INSTALLING DEPENDENCIES |"
        $DOAS pkg install \
        i3 i3status alacritty tmux xorg \
        git feh dmenu fastfetch
        echo "| DONE |"
}

main() {
        update_system
        install_deps
        copy_config
        echo "| RESTARTING + RELOADING I3 |"
        i3 --get-socketpath
        i3-msg reload && i3-msg restart || true
}
main "$@"
