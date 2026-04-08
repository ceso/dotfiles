set -g __fish_git_prompt_showdirtystate 1
set -g __fish_git_prompt_showstashstate 1
set -g __fish_git_prompt_showuntrackedfiles 1
set -g __fish_git_prompt_show_informative_status 1
set -g __fish_git_prompt_color_branch fab387
set -g __fish_git_prompt_color_dirtystate yellow
set -g __fish_git_prompt_color_stagedstate green
set -g __fish_git_prompt_color_untrackedfiles red
set -g __fish_git_prompt_color_upstream cyan
set -g __fish_git_prompt_color_stashstate magenta

function prompt_git
    fish_git_prompt ' (%s)'
end
