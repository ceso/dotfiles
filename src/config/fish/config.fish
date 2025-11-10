#!/usr/bin/env fish

# set -U fish_greeting ""

set -gx PATH /usr/local/bin /usr/bin /bin /usr/local/sbin /usr/sbin /sbin
set -gx EDITOR /usr/bin/vim
set -gx PAGER /usr/bin/less
set -gx LC_ALL 'en_US.UTF-8'
set -gx LANG 'en_US.UTF-8'
umask 0077

if test -f ~/.config/fish/config.local.fish
    . ~/.config/fish/config.local.fish
end
