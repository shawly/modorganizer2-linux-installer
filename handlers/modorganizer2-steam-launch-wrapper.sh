#!/usr/bin/env bash
# =============================================================================
# Steam Launch Option Wrapper for ModOrganizer 2
# Author: shawly (https://github.com/shawly)
#
# Description:
#   This script is designed to be used as a Steam Launch Option wrapper for
#   games managed by ModOrganizer 2 on Linux. It automatically detects the
#   correct ModOrganizer 2 instance based on the Steam App ID, replaces the
#   game executable argument with the ModOrganizer executable, and handles
#   launch options required for proper integration.
#
#   This script relies on the directory structure and configuration files
#   created by the installer:
#   https://github.com/Furglitch/modorganizer2-linux-installer
#
# Usage:
#   Add the following to your game's Steam Launch Options:
#   /usr/local/bin/modorganizer2 %command%
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Function Definitions
# -----------------------------------------------------------------------------

# Finds the variables.sh config file associated with the current Steam App ID
find_instance_config() {
    local steam_id="${1:-}"
    local config_file

    if [[ -z "$steam_id" ]]; then
        return 1
    fi

    for config_file in "$HOME/.config/modorganizer2/instances/"*"/variables.sh"; do
        [[ -e "$config_file" ]] || continue
        # use a subshell to check content without polluting current environment
        if ( source "$config_file" && [[ "${game_steam_id:-}" == "$steam_id" ]] ); then
            echo "$config_file"
            return 0
        fi
    done
    return 1
}

log_debug_info() {
    local log_file="/tmp/modorganizer2-steam-launch-wrapper_debug.log"
    {
        echo "=========================================="
        echo "Timestamp: $(date)"
        echo "Launch Arguments: $*"
        echo "------------------------------------------"
        echo "ENVIRONMENT VARIABLES:"
        printenv | sort
        echo "=========================================="
    } >> "$log_file"
}

usage() {
    echo "Add these launch options to your game in Steam to run it through ModOrganizer 2:"
    echo "    $0 %command%"
    exit 1
}

# -----------------------------------------------------------------------------
# Main Execution
# -----------------------------------------------------------------------------

main() {
    local steam_game_id="${SteamGameId:-}"
    
    if [[ -z "$steam_game_id" ]]; then
        echo "Error: SteamGameId environment variable is not set."
        zenity --error --text="Error: SteamGameId environment variable is not set.\nThis wrapper must be launched from Steam." 2>/dev/null || true
        exit 1
    fi

    local instance_config
    if ! instance_config=$(find_instance_config "$steam_game_id"); then
        echo "Error: ModOrganizer 2 instance not found for Steam App ID $steam_game_id"
        zenity --error --text="ModOrganizer 2 instance not found for Steam App ID $steam_game_id" 2>/dev/null || true
        exit 1
    fi

    # Load configuration
    # These variables are sourced from variables.sh:
    #   game_executable
    #   game_steam_id
    #   ...
    source "$instance_config"

    local instance_dir
    instance_dir="$(dirname "$instance_config")"
    
    local mo2_path="$instance_dir/modorganizer2/ModOrganizer.exe"
    local target_executable="${game_executable:-}"

    if [ ! -f "$mo2_path" ]; then
        echo "Error: ModOrganizer executable not found at $mo2_path"
        zenity --error --text="ModOrganizer executable not found at:\n$mo2_path\n\nPlease check the installation." 2>/dev/null || true
        exit 1
    fi

    # Reconstruct the Argument List
    local launch_args=()
    local executable_replaced=0
    local arg

    for arg in "$@"; do
        # Check if this argument ends with our target filename
        if [[ "$arg" == *"$target_executable" ]]; then
            launch_args+=("$mo2_path")
            executable_replaced=1
        else
            launch_args+=("$arg")
        fi
    done

    if [ "$executable_replaced" -eq 0 ]; then
        echo -e "Warning: Could not find argument containing '$target_executable' for replacement.\nLaunching command as-is..."
        zenity --warning --text="Could not find argument containing '$target_executable' for replacement.\nLaunching command as-is..." 2>/dev/null || true
    fi

    # Only log if the MO2_LAUNCH_WRAPPER_DEBUG environment variable is set to 1
    if [[ "${MO2_LAUNCH_WRAPPER_DEBUG:-0}" -eq 1 ]]; then
        log_debug_info "$@"
    fi

    # Stop previous ModOrganizer.exe instances gracefully
    pkill -f "ModOrganizer.exe" || true

    # Check if any ModOrganizer.exe processes are still running and wait for them to exit
    while pgrep -f "ModOrganizer.exe" > /dev/null; do
        sleep 0.5
    done

    # If Steam Big Picture Mode is detected we launch the steam-bigpicture shortcut so the game starts directly.
    if [[ "${SteamTenFoot:-0}" -eq 1 ]] || [[ "${MO2_LAUNCH_WRAPPER_DIRECT_LAUNCH:-0}" -eq 1 ]]; then
        launch_args+=("moshortcut://steam-bigpicture")
    fi

    # Execute the modified command securely
    exec "${launch_args[@]}"
}

if [ "$#" -eq 0 ]; then
    usage
fi

main "$@"
