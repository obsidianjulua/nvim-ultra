-- lua/slime.lua

-- Configure vim-slime for Julia REPL interaction
vim.g.slime_target = "tmux"
vim.g.slime_default_config = {
    socket_name = "default",
    target_pane = "{last}"
}

-- Auto-configure, no prompts
vim.g.slime_dont_ask_default = 1

-- Julia-specific settings
vim.g.slime_cell_delimiter = "##"
vim.g.slime_preserve_curpos = 1  -- Keep cursor position

-- Super simple keymaps - just 3 to remember
vim.keymap.set('v', '<leader>s', '<Plug>SlimeRegionSend', { desc = 'Send selection to REPL' })
vim.keymap.set('n', '<leader>s', '<Plug>SlimeLineSend', { desc = 'Send line to REPL' })
vim.keymap.set('n', '<leader>S', '<Plug>SlimeSendCell', { desc = 'Send cell to REPL' })

-- Auto-send imports when opening Julia files
vim.api.nvim_create_autocmd("FileType", {
    pattern = "julia",
    callback = function()
    -- Auto-highlight cell boundaries
    vim.fn.matchadd('Comment', '^##.*$')
    end,
})
