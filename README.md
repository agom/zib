# Zib OS

Arch-based Linux remix.

**What you get:**
- Hyprland compositor with Waybar, Wofi, and Mako notifications
- `greetd` + `tuigreet` TUI login greeter
- Zsh shell with Neovim, lazygit, fzf, tmux, and modern CLI tools (`bat`, `eza`, `zoxide`, `ripgrep`)
- Automatic GPU driver detection (NVIDIA / Intel / AMD)
- Firefox, Thunar, VS Code (AUR), VLC, qBittorrent
- Catppuccin Mocha GTK theme with Candy icons (AUR)
- PipeWire audio, Bluetooth, NetworkManager

---

## Installation

### Prerequisites

- Arch Linux base ISO booted (live environment)
- Internet connection
- Target disk: `/dev/sda` (the config wipes this disk entirely — adjust `installer/archinstall/user_configuration.json` if needed)

### 1. Clone the repo

```bash
pacman -Sy --noconfirm git
git clone https://github.com/agom/zib.git
cd zib
```


### 2. Set your credentials

Edit `installer/archinstall/credentials.json` before running the installer:

```json
{
  "!root_password": "your-root-password",
  "!users": [
    {
      "username": "your-username",
      "!password": "your-password",
      "sudo": true,
      "groups": ["wheel"]
    }
  ]
}
```

The default username is `dev` with password `dev` (root password: `root`) — fine for a VM, change before any real use.

### 3. Run archinstall

Use the provided configuration files to perform the base install:

```bash
archinstall \
  --config installer/archinstall/user_configuration.json \
  --creds installer/archinstall/credentials.json
```

This installs a minimal base system with:
- Hostname: `zib`
- Bootloader: `systemd-boot`
- Audio: PipeWire
- Network: NetworkManager
- Kernel: `linux` (mainline)

When archinstall finishes, **do not reboot yet**. Choose "Return to menu" and exit to the live shell.

### 4. Copy scripts into the new system

```bash
cp installer/scripts/post_install.sh /mnt/root/
cp installer/scripts/first_boot.sh   /mnt/root/
cp installer/scripts/aur_install.sh  /mnt/home/dev/
```

### 5. Run the post-install script

Chroot into the new system and run the script, passing the username you set in `credentials.json`:

```bash
arch-chroot /mnt
bash /root/post_install.sh dev
```

This will:
- Install all packages (Hyprland stack, dev tools, fonts, apps)
- Detect your GPU and install the appropriate Vulkan / NVIDIA drivers
- Enable NetworkManager, Bluetooth, and `greetd` services
- Configure the `tuigreet` login greeter
- Set up the user's shell, groups, and Hyprland config

> **GPU override:** If GPU detection gives wrong results, set `ZIB_TERMINAL` to force a terminal:
> ```bash
> ZIB_TERMINAL=foot bash /root/post_install.sh dev
> ```

### 6. Reboot

```bash
exit        # exit chroot
reboot
```

Log in as `dev` through the TUI greeter. Hyprland will start automatically.

### 7. Install AUR packages

Once inside the desktop, open a terminal (`Super+Return`) and run:

```bash
bash ~/aur_install.sh
```

This builds and installs `yay`, then installs:
- `visual-studio-code-bin`
- `candy-icons-git`
- `catppuccin-gtk-theme-mocha`

---

## Default keybindings

| Key              | Action              |
| ---------------- | ------------------- |
| `Super + Return` | Open terminal       |
| `Super + Space`  | App launcher (Wofi) |
| `Super + Q`      | Close window        |

---

## Post-install notes

- Run `update` in the terminal to update all system packages (`sudo pacman -Syu`).
- A Python virtual environment is pre-created at `~/.venv` and auto-activated in every new shell.
- Wayland environment variables (`MOZ_ENABLE_WAYLAND`, `XDG_SESSION_TYPE`, etc.) are set globally via `/etc/profile.d/zib-wayland.sh`.
- MIME defaults: Firefox for HTTP/HTTPS/HTML, Thunar for directories.
