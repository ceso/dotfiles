-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- ------------------------------------------
-- Options
-- ------------------------------------------
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

-- ------------------------------------------
-- Autocommands
-- ------------------------------------------
vim.api.nvim_create_autocmd({ "BufWritePre", "FileWritePre" }, {
    pattern = "*",
    callback = function()
        if not vim.bo.modifiable then
            return
        end
        local view = vim.fn.winsaveview()
        vim.cmd([[silent! keeppatterns keepjumps %s/\s\+$//e]])
        vim.cmd([[silent! keeppatterns keepjumps %s/\n\+\%$//e]])
        vim.fn.winrestview(view)
    end,
})

-- ------------------------------------------
-- Keymaps
-- ------------------------------------------
vim.g.mapleader = " "

vim.keymap.set("n", "<leader>cd", vim.cmd.Ex)
vim.keymap.set("n", "<leader>fb", "<cmd>Buffers<cr>")
vim.keymap.set("n", "<leader>ff", "<cmd>Files<cr>")
vim.keymap.set("n", "<leader>fh", "<cmd>Helptags<cr>")
vim.keymap.set("n", "<leader>gi", ":Rg ")

-- ------------------------------------------
-- Plugins
-- ------------------------------------------
require("lazy").setup({
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        lazy = false,
        opts = {
            flavour = "mocha",
            auto_integrations = true, -- modern + robust
        },
        config = function(_, opts)
            require("catppuccin").setup(opts)
            vim.cmd.colorscheme("catppuccin-nvim")
            vim.api.nvim_set_hl(0, "CursorColumn", { link = "CursorLine" })
            vim.api.nvim_set_hl(0, "CursorLine", { bg = "#3b384a", bold = true })
        end,
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "catppuccin" },
        config = function()
            local theme = require("catppuccin.utils.lualine")("mocha")

            require("lualine").setup({
                options = {
                    theme = theme,
                },
            })
        end,
    },
    {
        "editorconfig/editorconfig-vim"
    },
    {
        "junegunn/fzf.vim",
        dependencies = { "junegunn/fzf" },
    },
})

-- ------------------------------------------
-- Local overrides
-- ------------------------------------------
local local_config = vim.fn.stdpath("config") .. "/init.local.lua"
if vim.fn.filereadable(local_config) == 1 then
    dofile(local_config)
end
