# ~/.config/fish/conf.d/kubectl_abbr.fish

set -l __k_cmd kubectl
abbr --add k $__k_cmd
complete -c k -w $__k_cmd

# actions
create_abbr_subcmd $__k_cmd g get
create_abbr_subcmd $__k_cmd d describe
create_abbr_subcmd $__k_cmd del delete
create_abbr_subcmd $__k_cmd a apply
create_abbr_subcmd $__k_cmd e edit
create_abbr_subcmd $__k_cmd l logs
create_abbr_subcmd $__k_cmd x exec
create_abbr_subcmd $__k_cmd pf port-forward

# resources
create_abbr_subcmd $__k_cmd p pod
create_abbr_subcmd $__k_cmd pp pods
create_abbr_subcmd $__k_cmd sv service
create_abbr_subcmd $__k_cmd svv services
create_abbr_subcmd $__k_cmd n node
create_abbr_subcmd $__k_cmd nn nodes
create_abbr_subcmd $__k_cmd ns namespace
create_abbr_subcmd $__k_cmd dep deployment
create_abbr_subcmd $__k_cmd s secret
create_abbr_subcmd $__k_cmd ss secrets
create_abbr_subcmd $__k_cmd cm configmap
create_abbr_subcmd $__k_cmd ing ingress
create_abbr_subcmd $__k_cmd sa serviceaccount
create_abbr_subcmd $__k_cmd r role
create_abbr_subcmd $__k_cmd rr roles
create_abbr_subcmd $__k_cmd clr cloudroles
