-- lua/windows.lua
-- Enhanced window navigation for your multi-pane setup

local M = {}

function M.setup()
-- Better window navigation (Ctrl + hjkl)
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to bottom window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to top window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

-- Window resizing with arrow keys
vim.keymap.set('n', '<C-Up>', ':resize +2<CR>', { desc = 'Increase height' })
vim.keymap.set('n', '<C-Down>', ':resize -2<CR>', { desc = 'Decrease height' })
vim.keymap.set('n', '<C-Left>', ':vertical resize -2<CR>', { desc = 'Decrease width' })
vim.keymap.set('n', '<C-Right>', ':vertical resize +2<CR>', { desc = 'Increase width' })

-- Quick window operations
vim.keymap.set('n', '<leader>w', '<C-w>', { desc = 'Window operations' })
vim.keymap.set('n', '<leader>ws', ':split<CR>', { desc = 'Horizontal split' })
vim.keymap.set('n', '<leader>wv', ':vsplit<CR>', { desc = 'Vertical split' })
vim.keymap.set('n', '<leader>wq', ':close<CR>', { desc = 'Close window' })
vim.keymap.set('n', '<leader>wo', ':only<CR>', { desc = 'Close other windows' })
vim.keymap.set('n', '<leader>w=', '<C-w>=', { desc = 'Equalize windows' })

-- Better split borders
vim.opt.fillchars:append({
    horiz = '━',
    horizup = '┻',
    horizdown = '┳',
    vert = '┃',
    vertleft = '┫',
    vertright = '┣',
    verthoriz = '╋',
})

-- Auto-equalize windows when one closes
vim.api.nvim_create_autocmd("WinClosed", {
    callback = function()
    vim.cmd("wincmd =")
    end,
})

-- Auto-resize splits when terminal is resized
vim.api.nvim_create_autocmd("VimResized", {
    callback = function()
    vim.cmd("wincmd =")
    end,
})

-- Highlight active window
vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter" }, {
    callback = function()
    vim.opt_local.cursorline = true
    end,
})

vim.api.nvim_create_autocmd("WinLeave", {
    callback = function()
    vim.opt_local.cursorline = false
    end,
})
end

return M
