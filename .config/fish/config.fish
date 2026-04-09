# ~/.config/fish/config.fish

status is-interactive; or return
# sudo chfn -o other='umask=077'
if test (umask) != "0077"
    umask 0077
end

set -gx LANG "en_US.UTF-8"
set -gx LC_ALL "en_US.UTF-8"

set -e -Ugl PATH
fish_add_path --path --append (
    path resolve /usr/bin /bin /usr/sbin /sbin
)

set -e -Ugl fish_user_paths
fish_add_path ~/.local/bin
fish_add_path ~/bin

set -gx EDITOR nvim
set -gx PAGER bat
set -gx COPIER_SETTINGS_PATH ~/.config/copier/settings.yaml
set -gx FZF_DEFAULT_COMMAND 'fd --type=file --hidden --follow'
set -x THEFUCK_OVERRIDDEN_ALIASES 'nvim,bat,nvimdiff,eza'
set -g fish_escape_delay_ms 30
set -g fish_greeting ''

/home/linuxbrew/.linuxbrew/bin/brew shellenv | source

batman --export-env | source
fzf --fish | source
zoxide init fish | source
thefuck --alias | source

if test -f ~/.config/fish/config.local.fish
    . ~/.config/fish/config.local.fish
end
