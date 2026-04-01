-- ~/.config/nvim/conf.d/autocmds.lua

-- Trim trailing whitespace and empty lines before saving
vim.api.nvim_create_autocmd({ "BufWritePre", "FileWritePre" }, {
    pattern = "*",
    callback = function()
        if not vim.bo.modifiable then return end

        -- Save cursor position
        local view = vim.fn.winsaveview()

        -- Trim trailing whitespace
        local line_count = vim.fn.line("$")
        for i = 1, line_count do
            local line = vim.fn.getline(i)
            local trimmed = line:gsub("%s+$", "")
            if line ~= trimmed then
                vim.fn.setline(i, trimmed)
            end
        end

        -- Remove empty lines at the end
        while line_count > 0 and vim.fn.getline(line_count):match("^%s*$") do
            vim.fn.deletebufline(0, line_count)
            line_count = line_count - 1
        end

        -- Restore cursor
        vim.fn.winrestview(view)
    end,
})

-- Auto-save buffers on edit
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    pattern = "*",
    callback = function()
        if vim.bo.modifiable and not vim.bo.readonly then
            vim.api.nvim_command("silent! write")
        end
    end,
})

-- Plugin hooks:
-- * Treesitter auto-update on PackChanged
vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(ev)
        if ev.data.spec.name == "nvim-treesitter" and ev.data.kind == "update" then
            -- Ensure plugin is loaded
            if not ev.data.active then
                vim.cmd.packadd("nvim-treesitter")
            end
            -- Update Treesitter parsers
            require("nvim-treesitter.install").update({ with_sync = true })
        end
    end,
})
