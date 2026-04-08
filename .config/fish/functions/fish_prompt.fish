# ~/.config/fish/functions/fish_prompt.fish

set -g __prompt_color_env 40a02b
set -g __prompt_color_delimiter fab387
set -g __prompt_color_time a6e3a1
set -g fish_prompt_pwd_dir_length 3

function __prompt_out
    set_color $argv[1]
    echo -ns $argv[2..]
    set_color normal
end

function fish_prompt
    echo
    set_color $__prompt_color_delimiter
    echo -ns "╭─"
    set_color normal

    __prompt_out $__prompt_color_env (prompt_identity)
    prompt_git
    prompt_k8s

    echo
    set_color $__prompt_color_delimiter
    echo -ns "╰─"
    set_color $__prompt_color_delimiter
    printf '⋊> '
    set_color normal
end

function fish_right_prompt
    set_color $__prompt_color_time
    printf '(%s) ' (date '+%H:%M:%S %Z')
    set_color normal
end
