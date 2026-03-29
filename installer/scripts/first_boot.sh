#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <username>"
  exit 1
fi

TARGET_USER="$1"
USER_HOME="/home/$TARGET_USER"

if ! id "$TARGET_USER" >/dev/null 2>&1; then
  echo "User '$TARGET_USER' does not exist"
  exit 1
fi

install -d -o "$TARGET_USER" -g "$TARGET_USER" "$USER_HOME/.venv"
su - "$TARGET_USER" -c "python -m venv '$USER_HOME/.venv'"

install -d -o "$TARGET_USER" -g "$TARGET_USER" "$USER_HOME/.config/ghostty"
cat >"$USER_HOME/.config/ghostty/config" <<'EOF'
theme = catppuccin-mocha
font-family = JetBrainsMono Nerd Font
font-size = 12
cursor-style = block
EOF
chown "$TARGET_USER:$TARGET_USER" "$USER_HOME/.config/ghostty/config"

install -d -o "$TARGET_USER" -g "$TARGET_USER" "$USER_HOME/.config/hypr"
if [[ ! -f "$USER_HOME/.config/hypr/hyprland.conf" ]]; then
  cat >"$USER_HOME/.config/hypr/hyprland.conf" <<'EOF'
exec-once = waybar
exec-once = mako
exec-once = udiskie --notify
exec-once = wl-paste --type text --watch cliphist store

$mod = SUPER
bind = $mod, SPACE, exec, walker
bind = $mod SHIFT, RETURN, exec, ghostty
EOF
  chown "$TARGET_USER:$TARGET_USER" "$USER_HOME/.config/hypr/hyprland.conf"
fi
