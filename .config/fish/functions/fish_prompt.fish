set -g __prompt_color_ssh purple
set -g __prompt_color_git yellow
set -g __prompt_color_pwd cyan
set -g __prompt_max_pwd_len 50

function __prompt_out
    set_color $argv[1]
    echo -ns $argv[2..]
    set_color normal
end

function __prompt_ssh
    if set -q SSH_TTY
        __prompt_out $__prompt_color_ssh "$hostname "
    end
end

function __prompt_git
    set -l branch (git branch --show-current 2>/dev/null)
    or return
    set -l dirty ""
    if not git diff --quiet 2>/dev/null; or not git diff --cached --quiet 2>/dev/null
        set dirty " ±"
    end
    __prompt_out $__prompt_color_git " [$branch$dirty]"
end

function __prompt_pwd
    set -l dir (string replace -- $HOME "~" $PWD)
    if test (string length -- $dir) -gt $__prompt_max_pwd_len
        set -l parts (string split "/" -- $dir)
        while test (string length -- $dir) -gt $__prompt_max_pwd_len; and test (count $parts) -gt 2
            set parts "…" $parts[3..]
            set dir (string join "/" -- $parts)
        end
    end
    __prompt_out $__prompt_color_pwd $dir
end

function __prompt_status
    for exit_code in $argv
        if test $exit_code -ne 0
            __prompt_out red " [$exit_code]"
            break
        end
    end
end

function fish_prompt
    set -l last_status $status $pipestatus
    echo
    echo -ns (__prompt_ssh) (__prompt_pwd) (__prompt_git) (__prompt_status $last_status)
    echo
    echo -ns "❯ "
end
