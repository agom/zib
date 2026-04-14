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

# Create Python venv — let python -m venv handle directory creation itself;
# pre-creating the directory causes python 3.11+ to error with EEXIST.
su - "$TARGET_USER" -c "python -m venv '$USER_HOME/.venv'"

# Detect terminal: prefer ghostty if installed, fall back to foot.
terminal_cmd="foot"
if command -v ghostty >/dev/null 2>&1; then
  terminal_cmd="ghostty"
fi

install -d -o "$TARGET_USER" -g "$TARGET_USER" "$USER_HOME/.config/hypr"
if [[ ! -f "$USER_HOME/.config/hypr/hyprland.conf" ]]; then
  cat >"$USER_HOME/.config/hypr/hyprland.conf" <<'EOF'
exec-once = waybar
exec-once = mako
exec-once = udiskie --notify
exec-once = wl-paste --type text --watch cliphist store

input {
  kb_options = caps:none
}

$mod = SUPER
bind = $mod, SPACE, exec, wofi --show drun
bind = $mod, RETURN, exec, __TERMINAL_CMD__
bind = $mod, Q, killactive
EOF
  # Safely escape the replacement string so sed is not confused by & or /
  escaped_cmd=$(printf '%s\n' "$terminal_cmd" | sed 's/[&\\/]/\\&/g')
  sed -i "s|__TERMINAL_CMD__|$escaped_cmd|" "$USER_HOME/.config/hypr/hyprland.conf"
  chown "$TARGET_USER:$TARGET_USER" "$USER_HOME/.config/hypr/hyprland.conf"
fi

# Run xdg-user-dirs-update here (real user session) so locale is correct.
su - "$TARGET_USER" -c "xdg-user-dirs-update"
