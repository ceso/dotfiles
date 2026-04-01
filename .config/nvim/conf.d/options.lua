-- ~/.config/nvim/conf.d/options.lua

-- UI Appearance
vim.opt.cursorline = true
vim.opt.cursorcolumn = true
vim.opt.laststatus = 2
vim.opt.listchars = { eol = "¬", tab = "▸ ", trail = ".", precedes = "<", extends = ">" }
vim.opt.number = true
vim.opt.numberwidth = 4
vim.opt.ruler = true
vim.opt.rulerformat = "%l,%v"
vim.opt.scrolloff = 10
vim.opt.showmode = false
vim.opt.termguicolors = true
vim.opt.virtualedit = "all"

-- Editing & Indentation
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.shiftround = true

-- Formatting & Text Behavior
vim.opt.formatoptions = "cqr"
vim.opt.textwidth = 78
vim.opt.colorcolumn = "+1"
vim.opt.wrap = false

-- Search & Navigation
vim.opt.ignorecase = true
vim.opt.incsearch = true
vim.opt.infercase = true
vim.opt.smartcase = true
vim.opt.whichwrap = "<,>,h,l"

-- System & Behavior
vim.opt.autowrite = true
vim.opt.wildmenu = true
