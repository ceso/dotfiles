# ~/.config/fish/conf.d/kubectl_abbr.fish

abbr --add k kubectl
complete -c k -w kubectl

# actions
_kabbr g get
_kabbr d describe
_kabbr del delete
_kabbr a apply
_kabbr e edit
_kabbr l logs
_kabbr x exec
_kabbr pf port-forward

# resources
_kabbr p pod
_kabbr pp pods
_kabbr sv service
_kabbr svv services
_kabbr n node
_kabbr nn nodes
_kabbr ns namespace
_kabbr dep deployment
_kabbr s secret
_kabbr ss secrets
_kabbr cm configmap
_kabbr ing ingress
_kabbr sa serviceaccount
_kabbr r role
_kabbr rr roles
_kabbr clr cloudroles
