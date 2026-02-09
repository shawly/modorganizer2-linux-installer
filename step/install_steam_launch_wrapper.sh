#!/usr/bin/env bash

# This script installs the generic steam launch wrapper into the user's local bin directory.

wrapper_src="$handlers/modorganizer2-steam-launch-wrapper.sh"
target_dir="$HOME/.local/bin"
target_file="$target_dir/modorganizer2-steam-launch-wrapper.sh"
symlink_file="$target_dir/modorganizer2"
symlink2_file="$HOME/.local/share/Steam/ubuntu12_32/steam-runtime/amd64/usr/bin/modorganizer2"

log_info "Installing Steam launch wrapper..."

mkdir -p "$target_dir"

if cp "$wrapper_src" "$target_file"; then
    chmod +x "$target_file"
    ln -sf "$target_file" "$symlink_file"
    ln -sf "$target_file" "$symlink2_file" || log_warn "Failed to create symlink at '$symlink2_file', but the wrapper is still installed at '$target_file'. You may need to use the full path in Steam launch options."
    log_info "Steam launch wrapper installed to '$target_file'"
    log_info "You can now use '$symlink_file %command%' as your Steam launch option."
    
    # Check if ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        log_warn "'$HOME/.local/bin' is not in your PATH. You may need to use the full path in Steam launch options."
    fi
else
    log_error "Failed to install Steam launch wrapper to '$target_file'"
    # Fallback to install dir if local bin fails? 
    # But strictly following "separate step" instruction.
fi
