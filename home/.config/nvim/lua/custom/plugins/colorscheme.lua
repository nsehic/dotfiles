return {
  'neanias/everforest-nvim',
  version = false,
  lazy = false,
  priority = 1000, -- make sure to load this before all the other start plugins
  -- Optional; default configuration will be used if setup isn't called.
  config = function()
    require('everforest').setup {
      background = 'hard',
      transparent_background_level = 0,
      italics = true,
      disable_italic_comments = false,
      ui_contrast = 'low',
      dim_inactive_windows = false,
      spell_foreground = false,
    }
    vim.cmd.colorscheme 'everforest'
  end,
}
