#!/usr/bin/env bash
# Workaround to install the Witcher 3 MO2 basic game and installer helper plugins
# This script is sourced by `step/apply_workarounds.sh` and expects
# `install_dir` to be set to the installation target directory.

if [ -z "${install_dir:-}" ]; then
    log_error "install_dir is not set; cannot install Witcher 3 plugins"
    return 1
fi

plugin_base_url="https://raw.githubusercontent.com/shawly/modorganizer-basic_games/refs/heads/master/games"
plugins_dir="$install_dir/modorganizer2/plugins"
game_plugin_dir="$plugins_dir/basic_games/games"
log_info "creating plugin directory '$game_plugin_dir'"
mkdir -p "$game_plugin_dir"

log_info "writing game_witcher3.py into MO2 installation"
curl -fsSL "$plugin_base_url/game_witcher3.py" -o "$game_plugin_dir/game_witcher3.py"
chmod 0644 "$game_plugin_dir/game_witcher3.py" || true

# The installer helper is a standalone MO2 plugin, so it lives next to basic_games
log_info "writing Witcher3Installer.py into MO2 installation"
curl -fsSL "$plugin_base_url/witcher3/Witcher3Installer.py" -o "$plugins_dir/Witcher3Installer.py"
chmod 0644 "$plugins_dir/Witcher3Installer.py" || true

log_info "Witcher 3 MO2 plugin installation complete"
