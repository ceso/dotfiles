-- ~/.config/nvim/init.lua

vim.loader.enable()

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local config_dir = vim.fn.stdpath("config")

-- Core settings
dofile(config_dir .. "/conf.d/options.lua")
dofile(config_dir .. "/conf.d/keymaps.lua")
dofile(config_dir .. "/conf.d/autocmds.lua")

-- Plugins
vim.pack.add({
    { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
    {
        src = "https://github.com/saghen/blink.cmp",
        name = "blink",
        version = vim.version.range('1.x')
    },
    "https://github.com/nvim-lualine/lualine.nvim",
    "https://github.com/SmiteshP/nvim-navic",
    "https://github.com/editorconfig/editorconfig-vim",
    "https://github.com/lukas-reineke/indent-blankline.nvim",
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/nvim-tree/nvim-tree.lua",
    "https://github.com/nvim-tree/nvim-web-devicons",
    "https://github.com/lewis6991/gitsigns.nvim",
    "https://github.com/karb94/neoscroll.nvim",
    "https://github.com/junegunn/fzf",
    "https://github.com/junegunn/fzf.vim",
    "https://github.com/akinsho/bufferline.nvim",
})

-- Theme
require("catppuccin").setup(dofile(config_dir .. "/conf.d/theme.lua"))
vim.cmd.colorscheme("catppuccin-nvim")

-- Treesitter
require("nvim-treesitter").setup(dofile(config_dir .. "/conf.d/treesitter.lua"))

-- Editor
require("ibl").setup(dofile(config_dir .. "/conf.d/editor.lua"))

-- File Tree
require("nvim-tree").setup(dofile(config_dir .. "/conf.d/file_tree.lua"))

-- fzf
dofile(config_dir .. "/conf.d/fzf.lua")

-- Bufferline
require("bufferline").setup(dofile(config_dir .. "/conf.d/bufferline.lua"))

-- Git
require("gitsigns").setup(dofile(config_dir .. "/conf.d/gitsigns.lua"))

-- Completion
require("blink.cmp").setup(dofile(config_dir .. "/conf.d/blink.lua"))

-- Navigation
require("neoscroll").setup()

-- Statusline
local navic = require("nvim-navic")
navic.setup(dofile(config_dir .. "/conf.d/navic.lua"))
--require("nvim-navic").setup(dofile(config_dir .. "/conf.d/navic.lua"))

local lualine_theme = require("catppuccin.utils.lualine")("mocha")
require("lualine").setup({
    options = {
        theme = lualine_theme,
    },
    sections = {
        lualine_c = {
            "filename",
            {
                function()
                    return navic.get_location()
                end,
                cond = function()
                    return navic.is_available()
                end,
            },
        },
    },
})

-- Local overrides
local local_config = config_dir .. "/init.local.lua"
if vim.fn.filereadable(local_config) == 1 then
    dofile(local_config)
end
