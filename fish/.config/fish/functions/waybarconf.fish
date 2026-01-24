function waybarconf --wraps='nvim ~/.config/waybar/config' --wraps='nvim ~/.config/waybar/config.jsonc' --description 'alias waybarconf=nvim ~/.config/waybar/config.jsonc'
    nvim ~/.config/waybar/config.jsonc $argv
end
