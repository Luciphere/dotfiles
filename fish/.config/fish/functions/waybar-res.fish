function waybar-res --wraps='killall waybar; waybar & disown' --description 'alias waybar-res=killall waybar; waybar & disown'
    killall waybar; waybar & disown $argv
end
