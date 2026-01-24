# My Dotfiles

Personal configuration files for my CachyOS setup.

## Contents

- **hypr/** - Hyprland window manager config
- **kitty/** - Kitty terminal config
- **waybar/** - Waybar status bar config
- **dunst/** - Dunst notification daemon config
- **scripts/** - Custom scripts
  - `mtui.sh` - Music TUI player for BluOS devices

## Installation

Clone this repo:
```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
```

### Symlink configs
```bash
ln -sf ~/dotfiles/hypr ~/.config/hypr
ln -sf ~/dotfiles/kitty ~/.config/kitty
ln -sf ~/dotfiles/waybar ~/.config/waybar
ln -sf ~/dotfiles/dunst ~/.config/dunst
```

### Install mtui script
```bash
sudo cp ~/dotfiles/scripts/mtui.sh /usr/local/bin/mtui
sudo chmod +x /usr/local/bin/mtui
```

Edit the script to configure your BluOS device IP and music directory.

## mtui - Music TUI Player

Terminal interface for BluOS/Bluesound devices.

**Requirements:** python, fzf, curl

**Setup:**
1. Configure firewall: `sudo ufw allow from YOUR_BLUOS_IP to any port 8000`
2. Edit script variables (NODE_IP, SERVER_IP, MUSIC_DIR)
3. Run: `mtui`

See script for more details.
