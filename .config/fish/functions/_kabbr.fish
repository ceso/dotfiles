# ~/.config/fish/functions/_kabbr.fish

function _kabbr
    abbr --add --position anywhere --command kubectl $argv
end
