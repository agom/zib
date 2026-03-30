#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <username>"
  exit 1
fi

TARGET_USER="$1"

if ! id "$TARGET_USER" >/dev/null 2>&1; then
  echo "User '$TARGET_USER' does not exist"
  exit 1
fi

log() {
  printf "\n==> %s\n" "$1"
}

ensure_line() {
  local line="$1"
  local file="$2"
  grep -Fqx "$line" "$file" 2>/dev/null || printf "%s\n" "$line" >>"$file"
}

install_repo_packages() {
  local packages=(
    base-devel
    git
    zsh
    openssh
    python
    python-pip
    neovim
    lazygit
    fzf
    ffmpeg
    vlc
    firefox
    qbittorrent
    bat
    ripgrep
    fd
    eza
    zoxide
    tree
    btop
    unzip
    zip xz wget
    curl
    rsync
    tmux
    stow
    networkmanager
    network-manager-applet
    iwd
    bluez
    bluez-utils
    blueman
    pipewire
    wireplumber
    pipewire-pulse
    pavucontrol
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    polkit
    polkit-gnome
    gnome-keyring
    udisks2
    udiskie
    gvfs
    thunar
    grim
    slurp
    wl-clipboard
    cliphist
    mako
    ttf-jetbrains-mono-nerd
    noto-fonts
    noto-fonts-emoji
    xdg-user-dirs
    hyprland
    waybar
    wofi
    foot
    greetd
    greetd-tuigreet
    xdg-utils
    pciutils
  )

  pacman -Syu --needed --noconfirm "${packages[@]}"
}

install_terminal_package() {
  log "Selecting terminal package"

  if [[ -n "${ZIB_TERMINAL:-}" ]]; then
    pacman -S --needed --noconfirm "$ZIB_TERMINAL"
    return
  fi

  if [[ -e /dev/dri/renderD128 ]]; then
    pacman -S --needed --noconfirm ghostty
  else
    pacman -S --needed --noconfirm foot
  fi
}

configure_services() {
  log "Enabling system services"
  systemctl enable NetworkManager.service
  systemctl enable bluetooth.service
  systemctl enable greetd.service
  systemctl set-default graphical.target
  systemctl disable getty@tty1.service || true
}

configure_greetd() {
  log "Configuring greetd + tuigreet"
  install -d /etc/greetd
  cat >/etc/greetd/config.toml <<EOF
[terminal]
vt = 1
switch = true

[default_session]
command = "/usr/bin/tuigreet --cmd /usr/bin/start-hyprland"
user = "greeter"
EOF
}

configure_gpu_defaults() {
  log "Applying GPU defaults"
  local hypr_env_file
  hypr_env_file="/home/$TARGET_USER/.config/hypr/envs.conf"
  install -d -o "$TARGET_USER" -g "$TARGET_USER" "/home/$TARGET_USER/.config/hypr"
  touch "$hypr_env_file"
  chown "$TARGET_USER:$TARGET_USER" "$hypr_env_file"

  if lspci | grep -qi nvidia; then
    pacman -S --needed --noconfirm nvidia-open-dkms nvidia-utils lib32-nvidia-utils
    install -d /etc/modprobe.d /etc/mkinitcpio.conf.d
    cat >/etc/modprobe.d/nvidia.conf <<EOF
options nvidia_drm modeset=1
EOF
    cat >/etc/mkinitcpio.conf.d/nvidia.conf <<EOF
MODULES+=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
EOF
    ensure_line "env = LIBVA_DRIVER_NAME,nvidia" "$hypr_env_file"
    ensure_line "env = __GLX_VENDOR_LIBRARY_NAME,nvidia" "$hypr_env_file"
  fi

  if lspci | grep -qi 'VGA.*Intel\|Display.*Intel'; then
    pacman -S --needed --noconfirm vulkan-intel
  fi

  if lspci | grep -qi 'VGA.*AMD\|Display.*AMD'; then
    pacman -S --needed --noconfirm vulkan-radeon
  fi
}

configure_user_defaults() {
  log "Setting user defaults"
  if [[ "$(stat -c %U "/home/$TARGET_USER")" != "$TARGET_USER" ]]; then
    log "Fixing home ownership for $TARGET_USER"
    chown -R "$TARGET_USER:$TARGET_USER" "/home/$TARGET_USER"
  fi

  chsh -s /bin/zsh "$TARGET_USER"
  usermod -aG wheel,audio,video,input,storage "$TARGET_USER"

  install -d -o "$TARGET_USER" -g "$TARGET_USER" "/home/$TARGET_USER/.config/systemd/user"
  cat >"/home/$TARGET_USER/.config/systemd/user/udiskie.service" <<EOF
[Unit]
Description=udiskie automount daemon

[Service]
Type=simple
ExecStart=/usr/bin/udiskie --no-automount=false --notify
Restart=on-failure

[Install]
WantedBy=default.target
EOF
  chown "$TARGET_USER:$TARGET_USER" "/home/$TARGET_USER/.config/systemd/user/udiskie.service"
  install -d -o "$TARGET_USER" -g "$TARGET_USER" "/home/$TARGET_USER/.config/systemd/user/default.target.wants"
  ln -sf ../udiskie.service "/home/$TARGET_USER/.config/systemd/user/default.target.wants/udiskie.service"
  chown -h "$TARGET_USER:$TARGET_USER" "/home/$TARGET_USER/.config/systemd/user/default.target.wants/udiskie.service"

  install -d /usr/local/bin
  cat >/usr/local/bin/zib-update <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "Updating system packages..."
sudo pacman -Syu
EOF
  chmod +x /usr/local/bin/zib-update

  cat >/etc/skel/.zshrc <<'EOF'
export EDITOR=nvim
export VISUAL=nvim

alias cat='bat'
alias ls='eza --group-directories-first'
alias ll='eza -la --group-directories-first'
alias update='zib-update'

eval "$(zoxide init zsh)"

if [[ -f "$HOME/.venv/bin/activate" ]]; then
  source "$HOME/.venv/bin/activate"
fi
EOF

  if [[ ! -f "/home/$TARGET_USER/.zshrc" ]]; then
    cp /etc/skel/.zshrc "/home/$TARGET_USER/.zshrc"
    chown "$TARGET_USER:$TARGET_USER" "/home/$TARGET_USER/.zshrc"
  fi

  su - "$TARGET_USER" -c "xdg-user-dirs-update"

  install -d -o "$TARGET_USER" -g "$TARGET_USER" "/home/$TARGET_USER/.config"
  cat >"/home/$TARGET_USER/.config/mimeapps.list" <<'EOF'
[Default Applications]
x-scheme-handler/http=firefox.desktop
x-scheme-handler/https=firefox.desktop
text/html=firefox.desktop
inode/directory=thunar.desktop
EOF
  chown "$TARGET_USER:$TARGET_USER" "/home/$TARGET_USER/.config/mimeapps.list"

  install -d /etc/profile.d
  cat >/etc/profile.d/zib-wayland.sh <<'EOF'
export MOZ_ENABLE_WAYLAND=1
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_TYPE=wayland
EOF
}

run_first_boot() {
  log "Running first-boot provisioning"
  /usr/local/bin/zib-first-boot "$TARGET_USER"
}

install_first_boot_script() {
  install -d /usr/local/bin
  cp /root/first_boot.sh /usr/local/bin/zib-first-boot
  chmod +x /usr/local/bin/zib-first-boot
}

main() {
  log "Installing repository packages"
  install_repo_packages
  install_terminal_package
  configure_services
  configure_greetd
  configure_gpu_defaults
  configure_user_defaults
  install_first_boot_script
  run_first_boot
  log "Post-install completed"
}

main
