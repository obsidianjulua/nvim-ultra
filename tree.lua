-- lua/tree.lua

local setup = function()
  require('nvim-tree').setup {
    sort_by = "case_sensitive",
    view = {
      width = 30,
    },
    renderer = {
      group_empty = true,
    },
    filters = {
      dotfiles = true,
      custom = { '.git', 'node_modules' },
    },
    git = {
      enable = true,
      ignore = false,
      show_on_dirs = true,
      show_on_open_dirs = true,
      disable_for_dirs = {},
      timeout = 400,
    },
    actions = {
      open_file = {
        quit_on_open = true,
      },
    },
  }

  -- Keymap to toggle NvimTree
  vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true, desc = 'Toggle NvimTree' })
end

return { setup = setup }