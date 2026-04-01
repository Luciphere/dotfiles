set -g fish_greeting ""

if status is-interactive
    # Prompt
    if type -q starship
        starship init fish | source
    end

    # Direnv
    if type -q direnv
        direnv hook fish | source
    end

    # Zoxide
    if type -q zoxide
        zoxide init fish --cmd cd | source
    end

    # Better ls
    if type -q eza
        alias ls='eza --icons --group-directories-first -1'
    end

    # Fastfetch: small greeting on login shells only
    if status is-login && type -q fastfetch
        echo
        fastfetch
    end
end
set -gx EDITOR hx
