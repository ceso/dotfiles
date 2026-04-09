# ~/.config/fish/functions/create_abbr_subcmd.fish

function create_abbr_subcmd
    abbr --add --position anywhere --command $argv
end
