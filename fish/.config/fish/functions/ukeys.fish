function ukeys --wraps='cd ~/dotfiles && git add . && git commit -m "Update: (date)" && git push && cd -' --wraps='cd ~/dotfiles && git add . && git commit -m "Update: $(date)" && git push && cd -' --description 'alias ukeys=cd ~/dotfiles && git add . && git commit -m "Update: $(date)" && git push && cd -'
    cd ~/dotfiles && git add . && git commit -m "Update: $(date)" && git push && cd - $argv
end
