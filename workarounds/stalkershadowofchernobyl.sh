#!/usr/bin/env bash
# Workaround to install S.T.A.L.K.E.R.: SoC MO2 basic game plugin
# This script is sourced by `step/apply_workarounds.sh` and expects
# `install_dir` to be set to the installation target directory.

if [ -z "${install_dir:-}" ]; then
    log_error "install_dir is not set; cannot install Stalker plugin"
    return 1
fi

game_plugin_dir="$install_dir/modorganizer2/plugins/basic_games/games"
log_info "creating plugin directory '$game_plugin_dir'"
mkdir -p "$game_plugin_dir"

log_info "Stalker SoC MO2 plugin source from GitHub"
plugin_url="https://raw.githubusercontent.com/shawly/modorganizer-basic_games/refs/heads/master/games/game_stalkershadowofchernobyl.py"

log_info "writing game_stalkershadowofchernobyl.py into MO2 installation"
curl -fsSL "$plugin_url" -o "$game_plugin_dir/game_stalkershadowofchernobyl.py"

chmod 0644 "$game_plugin_dir/game_stalkershadowofchernobyl.py" || true
log_info "Stalker SoC plugin installed to '$game_plugin_dir/game_stalkershadowofchernobyl.py'"

log_info "Stalker SoC MO2 plugin installation complete"
