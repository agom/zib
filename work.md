# Zib OS

Arch-based Linux remix.

## Project goals

- Provide a fast, opinionated desktop and terminal workflow for software development.
- Keep setup simple for fresh installs while staying close to Arch conventions.
- Ship sane defaults that are easy for users to customize.

## Out of scope

- [ ] Support every desktop environment.
- [ ] Build a fully custom package manager.
- [ ] Replace core Arch tooling.

## License

- MIT License

## Base stack

- [ ] Arch Linux base
- [ ] Hyprland + Waybar desktop session [x] Wofi as the default launcher (`Super + Space`) [x] Login/session path: `greetd` + `tuigreet` + Hyprland session [ ] Default shell policy: [x] `zsh` as default interactive shell [x] Keep `bash` for system compatibility [x] Do not install Oh My Zsh by default in v0 (can be optional later)
- [x] Ghostty as default terminal

## Default packages

- [ ] `base-devel` (GCC toolchain and build essentials)
- [ ] `python` (Python 3)
- [ ] `git`
- [ ] `yay` (AUR helper)
- [ ] `bat` (better `cat`)
- [ ] `neovim`
- [ ] `lazygit`
- [ ] `fzf`
- [ ] `ffmpeg`
- [ ] `vlc`
- [ ] `qbittorrent` (default torrent client)
- [x] VS Code via AUR (`visual-studio-code-bin`)
- [x] Firefox via official repos (`firefox`)

## CLI essentials (v0)

- [x] `ripgrep` (`rg`) for fast code/text search
- [x] `fd` for fast file discovery
- [x] `eza` for modern `ls` output
- [x] `zoxide` for smarter directory jumping
- [x] `tree` for directory previews
- [x] `btop` for system monitoring
- [x] `unzip` + `zip` for common archive formats
- [x] `xz` for `.xz`/`.tar.xz` support
- [x] `wget` + `curl` for downloads and HTTP testing
- [x] `rsync` for local/remote sync and backups
- [x] `tmux` for terminal multiplexing
- [x] `stow` for dotfiles management

## Core desktop services (v0 must-have)

- [ ] Network stack:
  - [ ] `networkmanager`
  - [ ] `network-manager-applet`
  - [x] `iwd` as Wi-Fi backend
  - [ ] Enable `NetworkManager.service`
- [ ] Bluetooth support:
  - [ ] `bluez`
  - [ ] `bluez-utils`
  - [ ] `blueman` (tray + device management)
  - [ ] Enable `bluetooth.service`
- [ ] Audio stack:
  - [ ] `pipewire`
  - [ ] `wireplumber`
  - [ ] `pipewire-pulse`
  - [ ] `pavucontrol` (volume/device UI)
- [ ] Desktop portals/screen sharing:
  - [ ] `xdg-desktop-portal-hyprland`
  - [ ] `xdg-desktop-portal-gtk`
- [ ] Auth and keyring policy:
  - [x] `polkit` + `polkit-gnome`
  - [x] `gnome-keyring` as default secret store for Chrome/VS Code
  - [x] `openssh` `ssh-agent` as default SSH key agent
- [ ] USB automount and removable media:
  - [ ] `udisks2`
  - [ ] `udiskie` (auto-mount daemon for Wayland setups)
  - [ ] `gvfs` (file-manager integration)
  - [ ] Start `udiskie` in user session by default
- [ ] Screenshots/clipboard/notifications:
  - [ ] `grim` + `slurp`
  - [ ] `wl-clipboard`
  - [ ] `cliphist` (clipboard history)
  - [ ] `mako` (notification daemon)
- [ ] Visual defaults (coherent app look):
  - [x] Default font set: `ttf-jetbrains-mono-nerd` + `noto-fonts` + `noto-fonts-emoji`
  - [x] Icon theme: Candy Icons (set as default)
  - [x] GTK theme: Catppuccin Mocha (dark)
  - [ ] Cursor theme: TBD
  - [x] Terminal theme: Catppuccin Mocha (dark) as default for Ghostty
- [ ] Update UX:
  - [x] Ship `zib-update` wrapper for `yay -Syu`
  - [x] Add clear update entry in Walker/terminal help output
- [ ] Recovery baseline:
  - [x] v0 recovery path: manual chroot recovery documentation
  - [ ] Add snapshot rollback docs once snapshot tooling is finalized
  - [ ] Publish rescue workflow in install docs

## GPU and graphics policy

- [x] Use hardware auto-detection during install to choose driver stack.
- [ ] Show detected GPU + planned driver packages in installer output before apply.
- [ ] AMD/Intel default path:
  - [ ] Use Mesa stack from official repos
  - [ ] Install vendor Vulkan driver (`vulkan-radeon` or `vulkan-intel`) when detected
- [ ] NVIDIA special handling path:
  - [ ] Detect NVIDIA generation and install matching branch
  - [ ] Newer GPUs: `nvidia-open-dkms` + `nvidia-utils` (+ required 32-bit libs)
  - [ ] Older supported GPUs: legacy NVIDIA branch (+ matching utils)
  - [ ] Configure early KMS for stability
  - [ ] Apply Hyprland NVIDIA environment defaults in `envs.conf`
- [ ] Provide fallback mode: generic/open-source graphics profile for troubleshooting.

## System defaults (v0)

- [x] Filesystem default: Btrfs with subvolumes (`@`, `@home`, `@var_log`, `@snapshots`).
- [x] Swap default: zram only (no dedicated swap partition in v0).
- [x] Hibernation: disabled by default in v0.
- [x] Locale default: `en_US.UTF-8`.
- [x] Keyboard layout default: `us`.
- [x] Timezone default: auto-detect during install, fallback to `UTC`.

## Python policy

- [x] Use Arch `python` package (Python 3) as the default `python` command.
- [x] No extra `python3-is-python`-style compatibility package required on Arch.

## Package sources

- [ ] Define package source policy per package:
  - [ ] Arch official repositories
  - [ ] AUR packages
  - [ ] Custom repository (future)
- [ ] Document trust and update policy for AUR packages.

## AUR workflow policy

- [x] AUR usage is open-ended but only after base install completes.
- [x] Trust model for v0: live upstream AUR (no internal mirror/snapshot yet).
- [x] User must review PKGBUILD changes before proceeding with package updates.
- [ ] Integrate AUR updates into `zib-update` (`yay -Syu`) with clear prompts.
- [ ] On AUR failure, continue system update and print a failed-package summary.

## Installer and setup flow

- [x] Installer path for v0: `archinstall` profile + post-install scripts
- [ ] Keep custom `archiso` profile as a future phase once defaults stabilize.
- [ ] Define first-boot setup steps.
- [x] Install target: UEFI-only (no legacy BIOS support in v0)
- [x] Disk policy: full-disk encryption is mandatory (non-optional)
- [x] Bootloader: `systemd-boot`
- [ ] Define `archinstall` deliverables:
  - [x] `installer/archinstall/user_configuration.json`
  - [x] `installer/archinstall/credentials.json` (template only, no secrets)
  - [x] `installer/scripts/post_install.sh`
  - [x] `installer/scripts/first_boot.sh`

## Post-install automation

- [ ] Create default Python virtual environment in `~/.venv`.
- [ ] Add shell integration in `~/.zshrc`:
  - [ ] initialize path/aliases/helpers
  - [ ] optional auto-activation behavior (to be defined)

## Release and QA checklist (v0)

- [ ] Build install image/script successfully.
- [ ] Test install in VM (UEFI, encrypted disk, Wi-Fi/Ethernet).
- [ ] Verify desktop session boots and key apps launch.
- [ ] Verify update path (`pacman` + AUR packages) works.
- [ ] Publish install + recovery docs.
