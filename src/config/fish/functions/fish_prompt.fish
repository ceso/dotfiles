set -g __prompt_color_env purple
set -g __prompt_color_git yellow
set -g __prompt_color_pwd cyan

function __prompt_out
    set_color $argv[1]
    echo -ns $argv[2..]
    set_color normal
end

function __prompt_env
    set -l environment
    if set -q WSL_DISTRO_NAME
        set environment "wsl:$WSL_DISTRO_NAME"
    else if set -q AWS_ENVIRONMENT
        set environment "aws:$AWS_ENVIRONMENT"
    else
        set environment "$user@$hostname"
    end
    __prompt_out $__prompt_color_env $environment
end

function __prompt_git
    set -l branch (git branch --show-current 2>/dev/null)
    if test $status -eq 0
        __prompt_out $__prompt_color_git "[$branch]"
    end
end

function __prompt_pwd
    set -l directory (prompt_pwd)
    __prompt_out $__prompt_color_env (prompt_pwd)
end

function __prompt_status
    for exit_code in $argv
        if test $exit_code -ne 0
            __prompt_out red "[$exit_code]"
            break
        end
    end
end

function fish_prompt
    set -l last_status $status $pipestatus
    echo -n \
        (__prompt_env) \
        (__prompt_pwd) \
        (__prompt_git) \
        (__prompt_status $last_status) \
        "❯ "
end
