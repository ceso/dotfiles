-- ~/.config/nvim/conf.d/keymaps.lua

vim.g.mapleader = " "

vim.keymap.set("n", "<leader>cd", "<cmd>NvimTreeToggle<cr>")
vim.keymap.set("n", "<leader>fb", "<cmd>Buffers<cr>")
vim.keymap.set("n", "<leader>ff", "<cmd>Files<cr>")
vim.keymap.set("n", "<leader>fh", "<cmd>Helptags<cr>")
vim.keymap.set("n", "<leader>gi", ":Rg ")
