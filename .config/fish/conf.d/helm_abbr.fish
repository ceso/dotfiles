# ~/.config/fish/conf.d/helm_abbr.fish

abbr --add h helm
complete -c h -w helm

_habbr t template
_habbr d dependency
_habbr l list
_habbr r repo
_habbr u upgrade
