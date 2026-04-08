# ~/.config/fish/functions/fish_prompt.fish

set -g __prompt_color_env 40a02b
set -g __prompt_color_git fab387
set -g __prompt_color_k8s 04a5e5
set -g __prompt_color_delimiter fab387
set -g __prompt_color_time a6e3a1

# output helper
function __prompt_out
    set_color $argv[1]
    echo -ns $argv[2..]
    set_color normal
end

function __prompt_path_short
    set -l fish_prompt_pwd_dir_length 1
    set -l short (prompt_pwd)
    set -l full (string replace -- $HOME '~' $PWD)
    set -l first (string match -r '^~/[^/]+' -- $full)
    and set short (string replace -r -- '^~/[^/]+' $first $short)
    echo $short
end

# [user@host:path]
function __prompt_identity
    __prompt_out $__prompt_color_env "[$USER@$hostname:"(string replace -- $HOME '~' $PWD)"]"
end

# (git)
function __prompt_git
    set -l branch (git branch --show-current 2>/dev/null)
    or return

    set -l unstaged (git diff --shortstat 2>/dev/null)
    set -l staged   (git diff --cached --shortstat 2>/dev/null)

    if test -z "$unstaged$staged"
        __prompt_out $__prompt_color_git "($branch)"
        return
    end

    set -l added 0
    set -l removed 0

    for s in $unstaged $staged
        set -l a (string replace -r '.* ([0-9]+) insertion.*' '$1' -- $s)
        string match -qr '^[0-9]+$' -- $a; and set added (math $added + $a)

        set -l r (string replace -r '.* ([0-9]+) deletion.*' '$1' -- $s)
        string match -qr '^[0-9]+$' -- $r; and set removed (math $removed + $r)
    end

    __prompt_out $__prompt_color_git "($branch"

    set -l printed 0

    if test $added -gt 0
        set_color green
        echo -ns " +$added"
        set_color normal
        set printed 1
    end

    if test $removed -gt 0
        set_color red
        echo -ns " -$removed"
        set_color normal
        set printed 1
    end

    if test $printed -eq 0
        __prompt_out $__prompt_color_git " ±"
    end

    echo -ns ")"
end

# {k8s}
function __prompt_k8s
    command -q kubectx; or return
    command -q kubens; or return

    set -l ctx (kubectx -c 2>/dev/null)
    test -n "$ctx"; or return

    set -l ns (kubens -c 2>/dev/null)
    test -z "$ns"; and set ns default

    set -l value "$ctx/$ns"

    if string match -qi '*prod*' -- $value
        __prompt_out $__prompt_color_warning "{⚠️ $value ⚠️}"
    else
        __prompt_out $__prompt_color_k8s "{$value}"
    end
end

# Fish prompt (main)
function fish_prompt
    echo
    set_color $__prompt_color_delimiter
    echo -ns "╭─"
    set_color normal

    __prompt_identity
    __prompt_git
    __prompt_k8s

    echo
    set_color $__prompt_color_delimiter
    echo -ns "╰─"
    set_color $__prompt_color_delimiter
    printf '⋊> '
    set_color normal
end

# Fish right prompt (time)
function fish_right_prompt
    set_color $__prompt_color_time
    printf '(%s) ' (date '+%H:%M:%S %Z')
    set_color normal
end

