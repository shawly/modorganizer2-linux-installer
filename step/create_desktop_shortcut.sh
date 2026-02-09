#!/usr/bin/env bash

# This script creates a desktop shortcut for the MO2 instance.

# -----------------------------------------------------------------------------
# Icon Handling
# -----------------------------------------------------------------------------
icon_name="modorganizer2"
icon_url="https://cdn2.steamgriddb.com/icon/98c153eda30b9d78a78fb3cccae14eb7.png"
temp_icon="/tmp/mo2_icon.png"

log_info "Ensuring ModOrganizer 2 icon is installed..."

if curl -sSL "$icon_url" -o "$temp_icon"; then
    log_info "Downloaded ModOrganizer 2 icon to '$temp_icon'"
    
    # Use xdg-icon-resource to install the icon into the user's icon theme
    # This handles placing it in correct ~/.local/share/icons/... paths
    if command -v xdg-icon-resource >/dev/null; then
        xdg-icon-resource install --context apps --size 128 --novendor "$temp_icon" "$icon_name"
        log_info "Installed icon using xdg-icon-resource"
    else
        # Fallback if xdg-icon-resource is somehow missing despite dependency check
        mkdir -p "$HOME/.local/share/icons/hicolor/128x128/apps"
        cp "$temp_icon" "$HOME/.local/share/icons/hicolor/128x128/apps/${icon_name}.png"
        log_warn "xdg-icon-resource not found, manually copied icon"
    fi
    rm -f "$temp_icon"
else
    log_warn "Failed to download icon from '$icon_url'. Shortcut will use generic icon."
fi

# -----------------------------------------------------------------------------
# Shortcut Creation
# -----------------------------------------------------------------------------

log_info "Creating desktop shortcut for $selected_game..."

desktop_file="$HOME/.local/share/applications/${game_nexus_id}-mo2.desktop"

# Try to fetch the game name from Steam Store API
game_name="$game_nexus_id"
log_info "Fetching game name from Steam for AppID: $game_steam_id..."

if response=$(curl -s --max-time 10 "https://store.steampowered.com/api/appdetails?appids=$game_steam_id"); then
    if fetched_name=$(echo "$response" | jq -r ".\"$game_steam_id\".data.name" 2>/dev/null); then
         if [ -n "$fetched_name" ] && [ "$fetched_name" != "null" ]; then
             # Sanitize game name: remove pipes to avoid breaking sed, remove newlines
             game_name=$(echo "$fetched_name" | tr -d '|' | tr -d '\n')
             log_info "Identified game as '$game_name'"
         else
             log_warn "Could not extract game name from Steam API response. Using '$game_nexus_id'."
         fi
    else
        log_warn "Failed to parse Steam API response. Using '$game_nexus_id'."
    fi
else
    log_warn "Failed to connect to Steam API. Using '$game_nexus_id'."
fi

sed -e "s|{{ game_nexus_id }}|$game_nexus_id|g" \
    -e "s|{{ game_steam_id }}|$game_steam_id|g" \
    -e "s|{{ game_name }}|$game_name|g" \
    "$handlers/modorganizer2.desktop" > "$desktop_file"

# Make executable just in case
chmod +x "$desktop_file"

log_info "Desktop shortcut created at '$desktop_file'"

log_info "Refreshing desktop environment menu cache..."
if command -v update-desktop-database >/dev/null; then
    update-desktop-database "$HOME/.local/share/applications" || true
fi

if command -v kbuildsycoca6 >/dev/null; then
    kbuildsycoca6 --noincremental >/dev/null 2>&1 || true
elif command -v kbuildsycoca5 >/dev/null; then
    kbuildsycoca5 --noincremental >/dev/null 2>&1 || true
fi
