set -g __prompt_color_k8s 04a5e5
set -g __prompt_color_warning red

function prompt_k8s
    command -q kubectx; or return
    command -q kubens; or return

    set -l ctx (kubectx -c 2>/dev/null)
    test -n "$ctx"; or return

    set -l ns (kubens -c 2>/dev/null)
    test -z "$ns"; and set ns default

    set -l value "$ctx/$ns"

    if string match -qi '*prod*' -- $value
        set_color $__prompt_color_warning
        echo -ns "{⚠️ $value ⚠️}"
        set_color normal
    else
        set_color $__prompt_color_k8s
        echo -ns "{$value}"
        set_color normal
    end
end
