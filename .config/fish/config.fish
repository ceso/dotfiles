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

/home/linuxbrew/.linuxbrew/bin/brew shellenv | source

set -gx EDITOR vim
set -gx PAGER bat
set -gx COPIER_SETTINGS_PATH ~/.config/copier/settings.yaml
set -gx FZF_DEFAULT_COMMAND 'fd --type=file --hidden --follow'

batman --export-env | source
fzf --fish | source
zoxide init fish | source

alias cat=bat
alias vim=nvim
alias vimdiff=nvimdiff
alias ls="eza --classify=auto --color=auto --icons=auto -l -r -t modified"
alias ll="eza --classify=auto --color=auto --icons=auto -l -a -r -t modified"
alias la="eza --classify=auto --color=auto --icons=auto -l -a -h"
alias lz="eza --classify=auto --color=auto --icons=auto -l -Z"
alias laz="eza --classify=auto --color=auto --icons=auto -l -a -Z"

# Double ESC to re-run last command with sudo
bind \e\e sudo_last

if test -f ~/.config/fish/config.local.fish
    . ~/.config/fish/config.local.fish
end
