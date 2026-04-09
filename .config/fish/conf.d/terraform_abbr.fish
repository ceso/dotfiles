# ~/.config/fish/conf.d/terraform_abbr.fish

if command -q terraform
    set -l __tf_cmd terraform
else if command -q tofu
    set -l __tf_cmd tofu
end

test -n "$__tf_cmd"; or return

if not test -f ~/.config/fish/completions/$__tf_cmd.fish
    $__tf_cmd -install-autocomplete 2>/dev/null
    sed -i "s|.*/bin/$__tf_cmd|"(which $__tf_cmd)"|g" ~/.config/fish/completions/$__tf_cmd.fish
end

abbr --add t $__tf_cmd
complete -c t -w $__tf_cmd

create_abbr_subcmd $__tf_cmd i init
create_abbr_subcmd $__tf_cmd p plan
create_abbr_subcmd $__tf_cmd a apply
