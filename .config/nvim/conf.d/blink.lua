-- ~/.config/nvim/conf.d/blink.lua

return {
  keymap = { preset = 'default' },
  appearance = {
    nerd_font_variant = 'mono'
  },
  completion = {
    documentation = { auto_show = false }
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
        return { 'score', 'label' }  -- Prioritize label sorting for Lua files
      else
        return { 'score', 'sort_text', 'label' }  -- Default sorting for other filetypes
      end
    end,

    -- Frecency tracks the most recently/frequently used items and boosts the score of the item
    -- Note, this does not apply when using the Lua implementation.
    frecency = {
        enabled = true,
    }
  }
}
