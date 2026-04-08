-- ~/.config/nvim/conf.d/file_tree.lua

vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        -- Open nvim-tree always
        require("nvim-tree.api").tree.open()
    end,
})

vim.api.nvim_create_autocmd("VimResized", {
    callback = function()
        local api = require("nvim-tree.api")
        if api.tree.is_visible() then
            api.tree.close()
            api.tree.open()
        end
    end,
})

return {
    sort = { sorter = "case_sensitive" },
    view = {
        width = "30%",
        side = "left",
        preserve_window_proportions = true,
    },
    renderer = { group_empty = true,
        highlight_opened_files = "name",
        add_trailing = false,
        root_folder_label = function(path)
            return (vim.fn.fnamemodify(path, ":~"):gsub("(~/[^/]+)(.*)/([^/]+)$", function(head, mid, last)
                return head .. mid:gsub("/([^/][^/]?[^/]?)[^/]*", "/%1") .. "/" .. last
            end))
        end,
    },
    filters = { dotfiles = false },
    -- disable inotify watchers
    filesystem_watchers = { enable = false, },
    -- Always open tree
    hijack_directories = { enable = false },
    update_focused_file = { enable = true, update_root = false },
    actions = { open_file = { quit_on_open = false } },
}
