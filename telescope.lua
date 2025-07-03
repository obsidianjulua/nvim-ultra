-- lua/telescope.lua

local setup = function()
  local telescope = require('telescope')
  local actions = require('telescope.actions')

  telescope.setup({
    defaults = {
      -- Your default settings for Telescope
      mappings = {
        i = {
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
          ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
        },
      },
    },
    pickers = {
      -- Specific picker configurations
    },
    extensions = {
      -- Extension configurations
    },
  })

  -- Keymaps for Telescope
  vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { noremap = true, silent = true, desc = 'Find Files' })
  vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { noremap = true, silent = true, desc = 'Live Grep' })
  vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { noremap = true, silent = true, desc = 'Find Buffers' })
  vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { noremap = true, silent = true, desc = 'Help Tags' })
end

return { setup = setup }