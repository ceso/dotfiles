-- ~/.config/nvim/conf.d/blink.lua

return {
  keymap = {
      preset = 'default',
      ['<Tab>'] = { 'select_and_accept', 'fallback' }
  },
  appearance = {
    nerd_font_variant = 'mono'
  },
  completion = {
    menu = {
        auto_show = true,
    },
    documentation = {
        auto_show = true,
    },
    list = {
        selection = {
            preselect = true,
            auto_insert = false,
        },
    },
  },
  signature = { enabled = true,
    window = {
        show_documentation = false
    }
  },
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
  },
  fuzzy = {
    implementation = "prefer_rust_with_warning",
    prebuilt_binaries = {
        download = true,
    },
    sorts = function()
      if vim.bo.filetype == "lua" then
        -- Prioritize label sorting for Lua files
        return { 'score', 'label' }
      else
        -- Default sorting for other filetypes
        return { 'score', 'sort_text', 'label' }
      end
    end,
    -- Frecency tracks the most recently/frequently used items and boosts the score of the item
    -- Note, this does not apply when using the Lua implementation.
    frecency = {
        enabled = true,
    }
  }
}
