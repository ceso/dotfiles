#!/usr/bin/env fish

if status --is-interactive
    set -gx PATH /usr/local/bin /usr/bin /bin /usr/local/sbin /usr/sbin /sbin
    set -gx EDITOR /usr/bin/vim
    set -gx PAGER /usr/bin/less
    set -gx LC_ALL 'en_US.UTF-8'
    set -gx LANG 'en_US.UTF-8'
    set -U fish_greeting ""
    umask 0077
end

if test -f ~/.config/fish/config.local.fish
    . ~/.config/fish/config.local.fish
end
