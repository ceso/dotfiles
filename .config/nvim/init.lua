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
vim.g.mapleader = " "

vim.opt.cursorline = true
vim.opt.formatoptions = "tcqr"
vim.opt.laststatus = 2
vim.opt.listchars = { eol = "¬", tab = "▸ ", trail = ".", precedes = "<", extends = ">" }
vim.opt.ruler = true
vim.opt.scrolloff = 10
vim.opt.whichwrap = "<,>,h,l"
vim.opt.wildmenu = true

vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.softtabstop = 4
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.shiftround = true
vim.opt.wrap = false

vim.opt.ignorecase = true
vim.opt.incsearch = true
vim.opt.infercase = true
vim.opt.smartcase = true

vim.opt.number = true
vim.opt.numberwidth = 4
vim.opt.textwidth = 78
vim.opt.colorcolumn = "+1"
vim.opt.virtualedit = "all"
vim.opt.termguicolors = true
vim.opt.showmode = false

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
    opts = { flavour = "mocha" },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = { theme = "catppuccin" },
    },
  },
  { "editorconfig/editorconfig-vim" },
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
