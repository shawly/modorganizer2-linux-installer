#!/usr/bin/env bash
# Workaround to install the Witcher 3 MO2 basic game plugin
# This script is sourced by `step/apply_workarounds.sh` and expects
# `install_dir` to be set to the installation target directory.

if [ -z "${install_dir:-}" ]; then
    log_error "install_dir is not set; cannot install Witcher 3 plugin"
    return 1
fi

plugin_base_url="https://raw.githubusercontent.com/shawly/modorganizer-basic_games/refs/heads/master/games"
plugins_dir="$install_dir/modorganizer2/plugins"
game_plugin_dir="$plugins_dir/basic_games/games"
log_info "creating plugin directory '$game_plugin_dir/witcher3/plugins'"
mkdir -p "$game_plugin_dir/witcher3/plugins"

for plugin_file in \
	game_witcher3.py \
	witcher3/__init__.py \
	witcher3/settings_merge.py \
	witcher3/plugins/__init__.py
do
	log_info "writing '$plugin_file' into MO2 installation"
	curl -fsSL "$plugin_base_url/$plugin_file" -o "$game_plugin_dir/$plugin_file"
	chmod 0644 "$game_plugin_dir/$plugin_file" || true
done

# Superseded by the installer bundled with game_witcher3.py; both would claim the same archives
rm -f "$plugins_dir/Witcher3Installer.py"

log_info "Witcher 3 MO2 plugin installation complete"
