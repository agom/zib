#!/usr/bin/env bash

set -euo pipefail

if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
  echo "Run this script as a regular user, not root"
  exit 1
fi

log() {
  printf "\n==> %s\n" "$1"
}

require_command() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: $cmd"
    exit 1
  fi
}

install_yay() {
  if command -v yay >/dev/null 2>&1; then
    log "yay already installed"
    return
  fi

  log "Installing build prerequisites"
  sudo pacman -Syu --needed --noconfirm base-devel git go

  log "Building yay from AUR"
  local tmpdir
  tmpdir="$(mktemp -d)"
  git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
  (
    cd "$tmpdir/yay"
    makepkg -si --noconfirm
  )
  rm -rf "$tmpdir"
}

install_aur_packages() {
  log "Installing AUR defaults"
  yay -S --needed --noconfirm visual-studio-code-bin candy-icons-git catppuccin-gtk-theme-mocha
}

main() {
  require_command sudo
  require_command pacman
  require_command git

  install_yay
  install_aur_packages

  log "AUR setup completed"
}

main
