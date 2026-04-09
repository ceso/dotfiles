# ~/.config/fish/conf.d/helm_abbr.fish

set -l __h_cmd helm
abbr --add h $__h_cmd
complete -c h -w $__h_cmd

create_abbr_subcmd $__h_cmd t template
create_abbr_subcmd $__h_cmd d dependency
create_abbr_subcmd $__h_cmd l list
create_abbr_subcmd $__h_cmd r repo
create_abbr_subcmd $__h_cmd u upgrade
