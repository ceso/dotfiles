status is-interactive; or return

if test (umask) != "0077"
    echo >&2 "[WRN] default umask is $(umask). Forcing 0077."
    umask 0077
end

set -gx LANG "en_US.UTF-8"
set -gx LC_ALL "en_US.UTF-8"

set -e -Ugl PATH
fish_add_path --path --append (
    path resolve /snap/bin /usr/local/bin /usr/bin /bin /usr/local/sbin /usr/sbin /sbin
)

set -e -Ugl fish_user_paths
fish_add_path ~/.local/bin
fish_add_path ~/bin

switch (uname)
case Darwin
    /usr/local/bin/brew shellenv | source
case Linux
    /home/linuxbrew/.linuxbrew/bin/brew shellenv | source
end

set -gx EDITOR vim
set -gx PAGER bat
set -gx COPIER_SETTINGS_PATH ~/.config/copier/settings.yaml
set -gx FZF_DEFAULT_COMMAND 'fd --type=file --hidden --follow'

batman --export-env | source
fzf --fish | source
zoxide init fish | source

alias cat=bat
alias ls="eza --classify=auto --color=auto --icons=auto"

if test -f ~/.config/fish/config.local.fish
    . ~/.config/fish/config.local.fish
end
