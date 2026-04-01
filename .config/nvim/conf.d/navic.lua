-- ~/.config/nvim/conf.d/navic.lua

vim.api.nvim_set_hl(0, "NavicText",      { fg = "#ffffff" })
vim.api.nvim_set_hl(0, "NavicSeparator", { fg = "#888888" })

return {
    lsp = { auto_attach = true },
    highlight = true,
    separator = " > ",
}
