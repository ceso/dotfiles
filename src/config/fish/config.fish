set -gx PATH /usr/local/bin /usr/bin /bin /usr/local/sbin /usr/sbin /sbin
set -gx LC_ALL "en_US.UTF-8"
set -gx LANG "en_US.UTF-8"
umask 0077

if status is-interactive
    set -gx fish_user_paths ~/bin

    switch (uname)
    case Darwin
        eval (/usr/local/bin/brew shellenv)
    case Linux
        eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
    end

    set -gx EDITOR vim
    set -gx PAGER bat
    set -gx COPIER_SETTINGS_PATH ~/.config/copier/settings.yaml

    zoxide init fish | source

    if test -f ~/.config/fish/config.local.fish
        . ~/.config/fish/config.local.fish
    end
end
