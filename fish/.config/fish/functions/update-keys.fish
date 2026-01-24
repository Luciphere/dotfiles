function update-keys --wraps='sudo pacman -Sy archlinux-keyring cachyos-keyring; and sudo pacman-key --init; and sudo pacman-key --populate archlinux cachyos' --description 'alias update-keys=sudo pacman -Sy archlinux-keyring cachyos-keyring; and sudo pacman-key --init; and sudo pacman-key --populate archlinux cachyos'
    sudo pacman -Sy archlinux-keyring cachyos-keyring; and sudo pacman-key --init; and sudo pacman-key --populate archlinux cachyos $argv
end
