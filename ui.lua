-- lua/ui.lua

-- Core UI Settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes:2"  -- Always show 2 sign columns for more info
vim.opt.colorcolumn = "80,120"  -- Show code length guides
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.wrap = false
vim.opt.linebreak = true
vim.opt.showmode = false  -- Hide mode (statusline shows it)
vim.opt.showtabline = 2   -- Always show tabline
vim.opt.laststatus = 3    -- Global statusline
vim.opt.cmdheight = 0     -- Hide command line when not in use
vim.opt.pumheight = 15    -- Limit completion menu height

-- Indentation (Julia-focused)
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true

-- Better search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- Performance and files
vim.opt.updatetime = 250  -- Faster updates for better UX
vim.opt.timeoutlen = 300  -- Faster which-key
vim.opt.undofile = true
vim.opt.swapfile = false  -- Disable swap files
vim.opt.backup = false

-- Mouse and clipboard
vim.opt.mouse = "a"
vim.opt.clipboard:prepend({ "unnamedplus" })

-- Completion settings
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.pumblend = 10  -- Slightly transparent completion menu

-- Leaders
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Window transparency and borders
vim.opt.winblend = 0
vim.opt.pumblend = 15

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

-- Simple statusline with just the essentials
vim.opt.statusline = table.concat({
    ' %{toupper(mode())}',     -- Mode
    ' │ %t',                   -- Filename
    ' %m',                     -- Modified flag
    '%=',                      -- Right align
    ' %{&filetype}',           -- File type
    ' │ %l:%c',                -- Line:Column
    ' │ %p%% ',                -- Percentage
}, '')

-- Auto-resize windows when terminal is resized
vim.api.nvim_create_autocmd("VimResized", {
    callback = function()
    vim.cmd("wincmd =")
    end,
})

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
    end,
})

-- Auto-save when focus lost
vim.api.nvim_create_autocmd("FocusLost", {
    callback = function()
    if vim.bo.modifiable and vim.bo.modified then
        vim.cmd("silent! write")
        end
        end,
})

-- Diagnostic signs
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
    end

    -- Show diagnostics on cursor hold (simple version)
    vim.api.nvim_create_autocmd("CursorHold", {
        callback = function()
        vim.diagnostic.open_float(nil, {
            focusable = false,
            border = 'rounded',
            source = 'always',
        })
        end
    })
