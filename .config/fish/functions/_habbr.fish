# ~/.config/fish/functions/_habbr.fish

function _habbr
    abbr --add --position anywhere --command helm $argv
end
