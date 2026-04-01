-- ~/.config/nvim/conf.d/autocmds.lua

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
