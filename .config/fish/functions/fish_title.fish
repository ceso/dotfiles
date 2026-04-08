# ~/.config/fish/functions/fish_title.fish

function fish_title
    echo "[$USER@$hostname:"(__prompt_path_short)"]"
end

