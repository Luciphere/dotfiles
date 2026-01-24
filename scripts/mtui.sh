#!/bin/bash

# Load config from user's home directory
CONFIG_FILE="$HOME/.config/mtui/config"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    # Defaults (will prompt user to create config)
    NODE_IP="192.168.50.146:11000"
    SERVER_IP="192.168.50.32:8000"
    MUSIC_DIR="$HOME/Music"
    
    echo "No config found. Creating default config at $CONFIG_FILE"
    mkdir -p "$HOME/.config/mtui"
    cat > "$CONFIG_FILE" << EOF
# mtui configuration
NODE_IP="192.168.50.146:11000"
SERVER_IP="$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1 | head -1):8000"
MUSIC_DIR="$HOME/Music"
PLAYLIST_DIR="/tmp/mtui-playlists"
EOF
    echo "Please edit $CONFIG_FILE to set your IPs and music directory"
    exit 1
fi

PLAYLIST_DIR="${PLAYLIST_DIR:-/tmp/mtui-playlists}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# Create playlist directory
mkdir -p "$PLAYLIST_DIR"

# Function to check and start HTTP server if needed
check_http_server() {
    if ! curl -s --connect-timeout 2 "http://${SERVER_IP}/" > /dev/null 2>&1; then
        echo -e "${YELLOW}HTTP server not running. Starting it...${NC}"
        
        # Create symlink to playlists in music directory
        ln -sf "$PLAYLIST_DIR" "$MUSIC_DIR/playlists"
        
        cd "$MUSIC_DIR"
        nohup python -m http.server 8000 > /tmp/music-server.log 2>&1 &
        sleep 2
        
        if curl -s --connect-timeout 2 "http://${SERVER_IP}/" > /dev/null 2>&1; then
            echo -e "${GREEN}HTTP server started successfully${NC}"
            sleep 1
        else
            echo -e "${RED}Failed to start HTTP server${NC}"
            echo -e "${YELLOW}Please start it manually: cd $MUSIC_DIR && python -m http.server 8000 &${NC}"
            sleep 3
        fi
    fi
}

# Function to URL encode

# Function to URL encode
urlencode() {
    python3 -c "import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1]))" "$1"
}

# Function to create M3U playlist starting from selected file
create_playlist_from_file() {
    local file="$1"
    local folder=$(dirname "$MUSIC_DIR/$file")
    
    # Create playlist name based on file
    local playlist_name=$(echo "$file" | sed 's/[^a-zA-Z0-9]/_/g')
    local playlist_file="$PLAYLIST_DIR/${playlist_name}.m3u"
    
    echo "#EXTM3U" > "$playlist_file"
    
    # Get all music files in the same folder, sorted
    local all_files=()
    while IFS= read -r f; do
        all_files+=("$f")
    done < <(find "$folder" -maxdepth 1 -type f \( -name "*.flac" -o -name "*.mp3" \) | sort)
    
    # Find the index of the selected file
    local start_index=0
    for i in "${!all_files[@]}"; do
        if [ "${all_files[$i]}" = "$MUSIC_DIR/$file" ]; then
            start_index=$i
            break
        fi
    done
    
    # Add files to playlist starting from the selected file
    for (( i=$start_index; i<${#all_files[@]}; i++ )); do
        local relative_path="${all_files[$i]/$MUSIC_DIR\//}"
        local encoded=$(urlencode "$relative_path")
        echo "http://${SERVER_IP}/${encoded}" >> "$playlist_file"
    done
    
    echo "$playlist_file"
}

# Function to play a file (creates playlist with rest of folder)
play() {
    local file="$1"
    
    # Create playlist starting from this file
    local playlist_file=$(create_playlist_from_file "$file")
    local playlist_name=$(basename "$playlist_file")
    
    # Play the playlist via symlink
    local encoded=$(urlencode "playlists/$playlist_name")
    echo -e "${CYAN}Playing:${NC} ${BOLD}$(basename "$file")${NC} ${CYAN}(+ rest of folder)${NC}"
    curl -s "http://${NODE_IP}/Play?url=http://${SERVER_IP}/${encoded}" > /dev/null
}

# Function to get now playing (compact)
now_playing() {
    local xml=$(curl -s "http://${NODE_IP}/Status")
    local state=$(echo "$xml" | grep -oP '(?<=<state>)[^<]+')
    local streamUrl=$(echo "$xml" | grep -oP '(?<=<streamUrl>)[^<]+' | head -1)
    
    if [ "$state" = "play" ] || [ "$state" = "stream" ]; then
        if [ ! -z "$streamUrl" ]; then
            # Extract and parse filename
            local filename=$(basename "$streamUrl")
            # Remove .flac or .mp3 extension
            filename="${filename%.*}"
            # Remove .m3u extension if present
            filename="${filename%.*}"
            
            # Try to extract artist and title (assuming format: Artist - Album - Track Title.ext)
            if [[ "$filename" =~ ([^-]+)-([^-]+)-[0-9]+\ (.+) ]]; then
                local artist=$(echo "${BASH_REMATCH[1]}" | xargs)
                local title=$(echo "${BASH_REMATCH[3]}" | xargs)
                echo -e "${GREEN}▶${NC} ${BOLD}$title${NC} - $artist"
            else
                # Just show the cleaned filename
                echo -e "${GREEN}▶${NC} ${BOLD}$filename${NC}"
            fi
        else
            echo -e "${GREEN}▶${NC} Playing"
        fi
    elif [ "$state" = "pause" ]; then
        echo -e "${YELLOW}⏸${NC} Paused"
    else
        echo -e "${CYAN}⏹${NC} Stopped"
    fi
}

# FZF file browser with directories
browse() {
    local current_dir="$MUSIC_DIR"
    
    while true; do
        local fzf_input=""
        
        if [ "$current_dir" != "$MUSIC_DIR" ]; then
            fzf_input+=".. (parent directory)"$'\n'
        fi
        
        while IFS= read -r dir; do
            fzf_input+="[DIR] $(basename "$dir")"$'\n'
        done < <(find "$current_dir" -maxdepth 1 -type d ! -path "$current_dir" | sort)
        
        while IFS= read -r file; do
            local filename=$(basename "$file")
            fzf_input+="$filename"$'\n'
        done < <(find "$current_dir" -maxdepth 1 -type f \( -name "*.flac" -o -name "*.mp3" \) | sort)
        
        local selected=$(echo -n "$fzf_input" | 
            fzf --height=80% \
                --border \
                --layout=reverse \
                --prompt="$(echo ${current_dir/$MUSIC_DIR/~}): " \
                --header="ESC=cancel | ENTER=play" \
                --color="fg:#b4befe,bg:#1e1e2e,hl:#f38ba8" \
                --color="fg+:#cdd6f4,bg+:#313244,hl+:#f38ba8" \
                --color="info:#cba6f7,prompt:#89b4fa,pointer:#f5e0dc" \
                --color="marker:#a6e3a1,spinner:#f5e0dc,header:#94e2d5")
        
        if [ -z "$selected" ]; then
            return
        fi
        
        if [ "$selected" = ".. (parent directory)" ]; then
            current_dir=$(dirname "$current_dir")
        elif [[ "$selected" == \[DIR\]* ]]; then
            local dirname=$(echo "$selected" | sed 's/^\[DIR\] //')
            current_dir="$current_dir/$dirname"
        else
            local relative_path="${current_dir/$MUSIC_DIR\//}/$selected"
            play "$relative_path"
            echo -e "${GREEN}Started playback${NC}"
            sleep 1
            return
        fi
    done
}

# Main menu
main_menu() {
    check_http_server
    
    while true; do
        clear
        
        echo -e "${BOLD}Now Playing:${NC}"
        now_playing
        echo ""
        
        local choice=$(echo -e "(1) Browse\n(2) Pause/Resume\n(3) Stop\n(4) Volume\n(0) Quit" | 
            fzf --height=40% \
                --border \
                --layout=reverse \
                --prompt="Command: " \
                --header="Select action:" \
                --color="fg:#b4befe,bg:#1e1e2e,hl:#f38ba8" \
                --color="fg+:#cdd6f4,bg+:#313244,hl+:#f38ba8" \
                --color="info:#cba6f7,prompt:#89b4fa,pointer:#f5e0dc")
        
        case "$choice" in
            *"Browse"*)
                browse
                ;;
            *"Pause"*)
                # Check current state
                local xml=$(curl -s "http://${NODE_IP}/Status")
                local state=$(echo "$xml" | grep -oP '(?<=<state>)[^<]+')
                
                if [ "$state" = "pause" ]; then
                    # Currently paused, so resume
                    curl -s "http://${NODE_IP}/Play" > /dev/null
                    echo -e "${GREEN}Resumed${NC}"
                else
                    # Currently playing, so pause
                    curl -s "http://${NODE_IP}/Pause" > /dev/null
                    echo -e "${GREEN}Paused${NC}"
                fi
                sleep 1
                ;;
            *"Stop"*)
                curl -s "http://${NODE_IP}/Pause" > /dev/null
                echo -e "${GREEN}Stopped${NC}"
                sleep 1
                ;;
            *"Volume"*)
                clear
                echo -ne "${CYAN}Volume (0-100):${NC} "
                read vol
                curl -s "http://${NODE_IP}/Volume?level=$vol" > /dev/null
                echo -e "${GREEN}Volume set to $vol${NC}"
                sleep 1
                ;;
            *"Quit"*)
                clear
                echo -e "${CYAN}Goodbye!${NC}"
                exit 0
                ;;
            *)
                if [ -z "$choice" ]; then
                    clear
                    echo -e "${CYAN}Goodbye!${NC}"
                    exit 0
                fi
                ;;
        esac
    done
}

# Command line mode
if [ $# -eq 0 ]; then
    main_menu
else
    case "$1" in
        play)
            check_http_server
            if [ -z "$2" ]; then
                browse
            else
                play "$2"
            fi
            ;;
        browse)
            check_http_server
            browse
            ;;
        pause)
            curl -s "http://${NODE_IP}/Pause" > /dev/null
            ;;
        volume)
            if [ -z "$2" ]; then
                echo "Usage: mtui volume <0-100>"
                exit 1
            fi
            curl -s "http://${NODE_IP}/Volume?level=$2" > /dev/null
            ;;
        now)
            now_playing
            ;;
        *)
            echo "Usage: mtui [command]"
            echo ""
            echo "Commands:"
            echo "  (no args)    - Interactive menu"
            echo "  browse       - Browse music"
            echo "  play [file]  - Play specific file or browse"
            echo "  pause        - Pause/resume"
            echo "  volume <n>   - Set volume (0-100)"
            echo "  now          - Show now playing"
            exit 1
            ;;
    esac
fi
