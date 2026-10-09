
# Installer version (update this as needed)
installer_version="6.0.7"

# GitHub repo info; upstream moved to a Python rewrite, so releases of this fork are checked instead
repo="shawly/modorganizer2-linux-installer"
api_url="https://api.github.com/repos/$repo/releases/latest"

# Fetch latest release tag from GitHub
latest_version=$(curl -s "$api_url" | grep '"tag_name"' | head -1 | sed -E 's/.*"([^"]+)".*/\1/')

# This file is sourced by install.sh, so it must not exit when the check cannot run
if [ -z "$latest_version" ]; then
	log_info "Could not fetch latest release info from GitHub, skipping update check."
elif [ "$installer_version" != "$latest_version" ]; then
	log_warn "Your installer version ($installer_version) is not the latest release ($latest_version). Please update by visiting: https://github.com/$repo/releases/latest"
else
	log_info "Installer is up to date ($installer_version)."
fi
