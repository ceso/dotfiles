set -gx PATH /usr/local/bin /usr/bin /bin /usr/local/sbin /usr/sbin /sbin
set -gx EDITOR /usr/bin/vim
set -gx PAGER /usr/bin/less
set -gx LC_ALL 'en_US.UTF-8'
set -gx LANG 'en_US.UTF-8'
umask 0077

if status is-interactive
    set -gx fish_user_paths ~/bin
    set -gx COPIER_SETTINGS_PATH ~/.config/copier/settings.yaml

    set -l homebrew \
        /home/linuxbrew/.linuxbrew/bin/brew \
        /usr/local/bin/brew \
        brew
    for bin in $homebrew
        if test -x $bin
            set -gx HOMEBREW_NO_AUTO_UPDATE 1
            set -gx HOMEBREW_NO_ENV_HINTS 1
            set -gx HOMEBREW_NO_ANALYTICS 1
            eval ($bin shellenv)
            break
        end
    end

    set -l dircolors ~/.config/dircolors/solarized.256dark
    set -gx LS_COLORS (dircolors $dircolors | sh -c '. /dev/stdin; echo -n "${LS_COLORS}"')
end

if test -f ~/.config/fish/config.local.fish
    . ~/.config/fish/config.local.fish
end
