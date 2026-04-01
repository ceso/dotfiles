-- ~/.config/nvim/conf.d/file_tree.lua

vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        -- Open nvim-tree always
        require("nvim-tree.api").tree.open()
    end,
})

return {
    sort = { sorter = "case_sensitive" },
    view = {
        width = 60,
        side = "left",
        preserve_window_proportions = true,
    },
    renderer = { group_empty = true,
        highlight_opened_files = "name",
        add_trailing = false,
    },
    filters = { dotfiles = false },
    -- disable inotify watchers
    filesystem_watchers = { enable = false, },
    -- Always open tree
    hijack_directories = { enable = false },
    update_focused_file = { enable = true, update_root = false },
    actions = { open_file = { quit_on_open = false } },
}
