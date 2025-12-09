umask 0077
set -gx LANG "en_US.UTF-8"
set -gx LC_ALL "en_US.UTF-8"

set -e -Ugl PATH fish_user_paths
fish_add_path --path --append (
    path resolve /usr/local/bin /usr/bin /bin /usr/local/sbin /usr/sbin /sbin
)

if status is-interactive
    fish_add_path ~/bin
    fish_add_path ~/.local/bin

    switch (uname)
    case Darwin
        eval (/usr/local/bin/brew shellenv)
    case Linux
        eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
    end

    set -gx EDITOR vim
    set -gx PAGER bat
    set -gx COPIER_SETTINGS_PATH ~/.config/copier/settings.yaml

    batman --export-env | source
    zoxide init fish | source

    alias cat=bat
    alias ls="eza --classify=auto --color=auto --icons=auto"

    if test -f ~/.config/fish/config.local.fish
        . ~/.config/fish/config.local.fish
    end
end
