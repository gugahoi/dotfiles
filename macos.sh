#!/usr/bin/env bash
# macOS settings and Dock apps. Safe to re-run: each line sets one value.
# Tap to click, Spaces and dark mode apply after you log out and back in.
set -euo pipefail

# Appearance: dark mode.
defaults write -g AppleInterfaceStyle -string Dark

# Dock: 64px icons, no recent apps, Spaces keep their order (AeroSpace needs this).
defaults write com.apple.dock tilesize -int 64
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock mru-spaces -bool false

# "Displays have separate Spaces" off (AeroSpace recommends this).
defaults write com.apple.spaces spans-displays -bool true

# Clicking the wallpaper does not move all windows aside.
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false

# Finder: list view and status bar.
defaults write com.apple.finder FXPreferredViewStyle -string Nlsv
defaults write com.apple.finder ShowStatusBar -bool true

# No .DS_Store files on network or USB drives.
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Trackpad: tap to click (built-in and Magic Trackpad).
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write -g com.apple.mouse.tapBehavior -int 1

# Dock apps, left to right. Apps that are not installed are skipped.
dock_apps=("Rex Beta" Zen Claude "Microsoft Teams" "Microsoft Outlook")
defaults write com.apple.dock persistent-apps -array
for app in "${dock_apps[@]}"; do
    app_path="/Applications/$app.app"
    if [[ ! -d "$app_path" ]]; then
        echo "Skipping Dock app (not installed): $app"
        continue
    fi
    defaults write com.apple.dock persistent-apps -array-add \
        "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$app_path</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
done

killall Dock Finder 2>/dev/null || true
echo "Done. Log out and back in for tap to click, Spaces and dark mode."
