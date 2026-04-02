# Dotfiles

Personal configuration files for my CachyOS / Arch Linux setup, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Setup overview

| Component       | Program          |
|----------------|-----------------|
| Window manager  | Hyprland        |
| Terminal        | Kitty           |
| Shell           | Fish            |
| Editor          | Helix           |
| File manager    | Yazi (in Kitty) |
| App launcher    | Rofi            |
| Status bar      | Waybar          |
| Notifications   | Dunst           |
| Wallpaper       | awww            |
| Screen locker   | Hyprlock        |
| Screenshots     | Grim + Slurp    |
| Bluetooth       | Blueman         |
| Cloud sync      | Rclone          |
| Task manager    | Taskwarrior + taskwarrior-tui |
| Resource monitor| Btop            |
| System info     | Fastfetch       |

---

## 1. Install dependencies

### Core Hyprland stack
```bash
sudo pacman -S hyprland hyprlock xdg-desktop-portal-hyprland
```

### Terminal & shell
```bash
sudo pacman -S kitty fish
chsh -s /usr/bin/fish
```

### Editor & file manager
```bash
sudo pacman -S helix yazi
```

### App launcher
```bash
sudo pacman -S rofi-wayland
```

### Status bar & notifications
```bash
sudo pacman -S waybar dunst
```

### Wallpaper
```bash
yay -S awww
```

### Screen lock
```bash
sudo pacman -S hyprlock
```

### Screenshots
```bash
sudo pacman -S grim slurp wl-clipboard
```

### Audio (PipeWire)
```bash
sudo pacman -S pipewire pipewire-pulse wireplumber
```

### Brightness control
```bash
sudo pacman -S brightnessctl
```

### Bluetooth
```bash
sudo pacman -S blueman
sudo systemctl enable --now bluetooth
```

### Cloud sync (Dropbox + OneDrive)
```bash
sudo pacman -S rclone
```

Create the mount point directories:
```bash
mkdir -p ~/Dropbox ~/OneDrive
```

Configure the remotes interactively (requires a browser for OAuth):
```bash
rclone config
```

For **Dropbox**: choose `n` (new remote), name it `dropbox`, type `dropbox`, follow the OAuth flow.

For **OneDrive**: choose `n` (new remote), name it `onedrive`, type `onedrive`, follow the OAuth flow.

The mounts are launched automatically by Hyprland on login (see `hyprland.conf` autostart). To test them manually:
```bash
rclone mount dropbox: ~/Dropbox --vfs-cache-mode full --daemon
rclone mount onedrive: ~/OneDrive --vfs-cache-mode full --daemon
```

### Fonts
```bash
sudo pacman -S ttf-fantasque-nerd
```

### Task management
```bash
sudo pacman -S task taskwarrior-tui
```

### Utilities
```bash
sudo pacman -S btop fastfetch
```

---

## 2. Clone and apply with Stow

```bash
git clone https://github.com/Luciphere/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

Apply all configs at once:
```bash
stow --target="$HOME" btop dunst fastfetch fish helix hypr kitty micro mods waybar
```

Or apply individually, e.g.:
```bash
stow --target="$HOME" hypr
stow --target="$HOME" kitty
```

> **Note:** Stow creates symlinks from `~/.config/<app>` to the corresponding folder in this repo. If a config already exists, remove or back it up first.

---

## 3. Keybindings

| Shortcut             | Action                        |
|---------------------|-------------------------------|
| `Super + Q`         | Open terminal (Kitty)         |
| `Super + W`         | Open browser (Firefox)        |
| `Super + E`         | Open file manager (Yazi)      |
| `Super + Space`     | App launcher (Rofi)           |
| `Super + C`         | Close active window           |
| `Super + F`         | Fullscreen                    |
| `Super + V`         | Toggle floating               |
| `Super + Escape`    | Lock screen + suspend         |
| `Super + Shift + M` | Exit Hyprland                 |
| `Super + H/J/K/L`   | Move focus (vim-style)        |
| `Super + Shift + H/J/K/L` | Resize window           |
| `Super + 1–0`       | Switch workspace              |
| `Super + Shift + 1–0` | Move window to workspace    |
| `Super + S`         | Toggle scratchpad             |
| `Super + Shift + S` | Move to scratchpad            |
| `Print`             | Screenshot (full screen)      |
| `Shift + Print`     | Screenshot (select area)      |
| `Ctrl + Shift + Print` | Screenshot to clipboard    |

---

## mtui — Music TUI for BluOS

Terminal interface for BluOS/Bluesound devices.

**Requirements:** `python`, `fzf`, `curl`

```bash
sudo pacman -S python fzf curl
sudo cp ~/dotfiles/scripts/mtui.sh /usr/local/bin/mtui
sudo chmod +x /usr/local/bin/mtui
```

Create config:
```bash
mkdir -p ~/.config/mtui
nano ~/.config/mtui/config
```

```bash
NODE_IP="192.168.x.x:11000"     # Your BluOS device IP
SERVER_IP="YOUR_COMPUTER_IP:8000"
MUSIC_DIR="/home/YOUR_USERNAME/Music"
PLAYLIST_DIR="/tmp/mtui-playlists"
```

Allow firewall access from the BluOS device:
```bash
sudo ufw allow from 192.168.x.x to any port 8000
```

Run: `mtui`

---

## Claude Code (AI assistant in the terminal)

Install via npm:
```bash
sudo pacman -S nodejs npm
npm install -g @anthropic-ai/claude-code
```

Then run `claude` in any project directory. On first run it will ask you to log in with your Anthropic account.
