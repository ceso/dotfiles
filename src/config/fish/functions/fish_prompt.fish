function __prompt_host
    if set -q WSL_DISTRO_NAME
        echo -n "WSL/$WSL_DISTRO_NAME"
    else if set -q AWS_ENVIRONMENT
        echo -n "AWS/$AWS_ENVIRONMENT"
    else
        echo -n $hostname
    end
end

function fish_prompt
    set_color $fish_color_host
    __prompt_host

    set_color $fish_color_cwd
    echo -n " $(prompt_pwd)" # prompt_pwd prints LF unless captured

    set_color yellow
    __fish_git_prompt " [%s]"

    set_color normal
    echo -e "\n> "
end
