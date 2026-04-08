function fish_title
    set -l warn ""
    if string match -qi '*prod*' -- (hostname)
        set warn "⚠️ "
    end
    echo "$warn"(prompt_identity)
end
