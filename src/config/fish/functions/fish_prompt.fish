function fish_prompt
    echo -s (set_color green) (prompt_pwd)

    if set -q AWS_ENVIRONMENT
        echo -n -s (set_color blue) "{$AWS_ENVIRONMENT} "
    end

    echo -n -s (set_color yellow) (__fish_git_prompt "[%s] ")
    echo -n -s (set_color normal) "% "
end
