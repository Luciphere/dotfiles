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

1. Install dependencies:
```bash
   sudo pacman -S python fzf curl
```

2. Copy script:
```bash
   sudo cp ~/dotfiles/scripts/mtui.sh /usr/local/bin/mtui
   sudo chmod +x /usr/local/bin/mtui
```

3. Create config file (mtui will prompt on first run, or create manually):
```bash
   mkdir -p ~/.config/mtui
   nano ~/.config/mtui/config
```
   
   Add:
```bash
   # mtui configuration
   NODE_IP="192.168.50.146:11000"  # Your BluOS device IP
   SERVER_IP="YOUR_COMPUTER_IP:8000"  # This computer's IP
   MUSIC_DIR="/home/YOUR_USERNAME/Music"
   PLAYLIST_DIR="/tmp/mtui-playlists"
```

4. Configure firewall (IMPORTANT):
```bash
   sudo ufw allow from 192.168.50.146 to any port 8000
```

5. Run: `mtui`
