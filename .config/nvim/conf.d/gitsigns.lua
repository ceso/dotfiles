-- ~/.config/nvim/conf.d/gitsigns.lua

vim.api.nvim_set_hl(0, "GitSignsCurrentLineBlame", { fg = "#f5c2e7", italic = true })
vim.api.nvim_set_hl(0, "GitSignsAdd",    { fg = "#00ff00", bold = true })
vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#ffff00", bold = true })
vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#ff3333", bold = true })

return {
    current_line_blame = true
}
