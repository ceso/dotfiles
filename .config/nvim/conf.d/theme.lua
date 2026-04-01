-- ~/.config/nvim/conf.d/theme.lua

return {
    flavour = "mocha",
    auto_integrations = true,
    highlight_overrides = {
        mocha = function()
            return {
                CursorColumn = { link = "CursorLine" },
                CursorLine = { bg = "#3b384a", bold = true },
            }
        end,
    },
}
