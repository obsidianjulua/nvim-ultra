-- lua/widgets.lua
-- Additional UI widgets and enhancements

local M = {}

function M.setup()
  -- 1. Git Signs - Shows git changes in sign column (passive)
  if pcall(require, 'gitsigns') then
    require('gitsigns').setup {
      signs = {
        add          = { text = '│' },
        change       = { text = '│' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
        untracked    = { text = '┆' },
      },
      signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
      numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
      linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
      word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
      watch_gitdir = {
        follow_files = true
      },
      attach_to_untracked = true,
      current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false,
      },
      sign_priority = 6,
      update_debounce = 100,
      status_formatter = nil, -- Use default
      max_file_length = 40000, -- Disable if file is longer than this (in lines)
      preview_config = {
        -- Options passed to nvim_open_win
        border = 'single',
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1
      },
    }
  end

  -- 2. Indent Guides - Visual indentation lines (passive)
  if pcall(require, 'ibl') then
    require('ibl').setup {
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = {
        enabled = true,
        show_start = true,
        show_end = true,
        injected_languages = false,
        highlight = { "Function", "Label" },
        priority = 500,
      },
      exclude = {
        filetypes = {
          "help",
          "alpha",
          "dashboard",
          "nvim-tree",
          "Trouble",
          "trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
      },
    }
  end

  -- 3. Notifications - Better notification system (passive)
  if pcall(require, 'notify') then
    vim.notify = require("notify")
    require("notify").setup({
      background_colour = "#000000",
      fps = 30,
      icons = {
        DEBUG = "",
        ERROR = "",
        INFO = "",
        TRACE = "✎",
        WARN = ""
      },
      level = 2,
      minimum_width = 50,
      render = "wrapped-compact",
      stages = "fade_in_slide_out",
      time_formats = {
        notification = "%T",
        notification_history = "%FT%T"
      },
      timeout = 5000,
      top_down = true
    })
  end

  -- 4. Dashboard/Start Screen (passive)
  if pcall(require, 'alpha') then
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- Set header
    dashboard.section.header.val = {
      "                                                     ",
      "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
      "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
      "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
      "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
      "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
      "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
      "                                                     ",
    }

    -- Set menu
    dashboard.section.buttons.val = {
      dashboard.button("e", "  > New File", "<cmd>ene<CR>"),
      dashboard.button("SPC e", "  > File Explorer", "<cmd>NvimTreeToggle<CR>"),
      dashboard.button("SPC f f", "  > Find File", "<cmd>Telescope find_files<CR>"),
      dashboard.button("SPC f g", "  > Find Word", "<cmd>Telescope live_grep<CR>"),
      dashboard.button("SPC f r", "  > Recent", "<cmd>Telescope oldfiles<CR>"),
      dashboard.button("SPC f s", "  > Settings", "<cmd>e $MYVIMRC | :cd %:p:h <CR>"),
      dashboard.button("q", "  > Quit NVIM", "<cmd>qa<CR>"),
    }

    -- Footer with stats
    local function footer()
      local total_plugins = #vim.tbl_keys(packer_plugins or {})
      local datetime = os.date("%d-%m-%Y %H:%M:%S")
      local version = vim.version()
      local nvim_version_info = "  v" .. version.major .. "." .. version.minor .. "." .. version.patch

      return "⚡ " .. total_plugins .. " plugins" .. "  " .. datetime .. nvim_version_info
    end

    dashboard.section.footer.val = footer()

    alpha.setup(dashboard.opts)

    -- Disable folding on alpha buffer
    vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
  end

  -- 5. Scrollbar with diagnostics and search (passive)
  if pcall(require, 'scrollbar') then
    require("scrollbar").setup({
      show = true,
      show_in_active_only = false,
      set_highlights = true,
      folds = 1000, -- handle folds, set to number to disable folds if no. of lines in buffer exceeds this
      max_lines = false, -- disables if no. of lines in buffer exceeds this
      hide_if_all_visible = false, -- Hides everything if all lines are visible
      throttle_ms = 100,
      handle = {
        text = " ",
        color = nil,
        cterm = nil,
        highlight = "CursorColumn",
        hide_if_all_visible = true, -- Hides handle if all lines are visible
      },
      marks = {
        Cursor = {
          text = "•",
          priority = 0,
          color = nil,
          cterm = nil,
          highlight = "Normal",
        },
        Search = {
          text = { "-", "=" },
          priority = 1,
          color = nil,
          cterm = nil,
          highlight = "Search",
        },
        Error = {
          text = { "-", "=" },
          priority = 2,
          color = nil,
          cterm = nil,
          highlight = "DiagnosticVirtualTextError",
        },
        Warn = {
          text = { "-", "=" },
          priority = 3,
          color = nil,
          cterm = nil,
          highlight = "DiagnosticVirtualTextWarn",
        },
        Info = {
          text = { "-", "=" },
          priority = 4,
          color = nil,
          cterm = nil,
          highlight = "DiagnosticVirtualTextInfo",
        },
        Hint = {
          text = { "-", "=" },
          priority = 5,
          color = nil,
          cterm = nil,
          highlight = "DiagnosticVirtualTextHint",
        },
        Misc = {
          text = { "-", "=" },
          priority = 6,
          color = nil,
          cterm = nil,
          highlight = "Normal",
        },
        GitAdd = {
          text = "┆",
          priority = 7,
          color = nil,
          cterm = nil,
          highlight = "GitSignsAdd",
        },
        GitChange = {
          text = "┆",
          priority = 7,
          color = nil,
          cterm = nil,
          highlight = "GitSignsChange",
        },
        GitDelete = {
          text = "▁",
          priority = 7,
          color = nil,
          cterm = nil,
          highlight = "GitSignsDelete",
        },
      },
      excluded_buftypes = {
        "terminal",
      },
      excluded_filetypes = {
        "prompt",
        "TelescopePrompt",
        "noice",
        "alpha",
        "nvim-tree",
      },
      autocmd = {
        render = {
          "BufWinEnter",
          "TabEnter",
          "TermEnter",
          "WinEnter",
          "CmdwinLeave",
          "TextChanged",
          "VimResized",
          "WinScrolled",
        },
        clear = {
          "BufWinLeave",
          "TabLeave",
          "TermLeave",
          "WinLeave",
        },
      },
    })
  end

  -- 6. Smooth scrolling (passive)
  if pcall(require, 'neoscroll') then
    require('neoscroll').setup({
      mappings = {'<C-u>', '<C-d>', '<C-b>', '<C-f>',
                  '<C-y>', '<C-e>', 'zt', 'zz', 'zb'},
      hide_cursor = true,
      stop_eof = true,
      respect_scrolloff = false,
      cursor_scrolls_alone = true,
      easing_function = nil,
      pre_hook = nil,
      post_hook = nil,
      performance_mode = false,
    })
  end

  -- 7. Better quickfix and location list (passive)
  if pcall(require, 'trouble') then
    require("trouble").setup {
      icons = false,
      fold_open = "v", -- icon used for open folds
      fold_closed = ">", -- icon used for closed folds
      indent_lines = false, -- add an indent guide below the fold icons
      signs = {
        error = "E",
        warning = "W",
        hint = "H",
        information = "I"
      },
      use_diagnostic_signs = false -- enabling this will use the signs defined in your lsp client
    }
  end

  -- 8. Color highlighter (passive)
  if pcall(require, 'colorizer') then
    require('colorizer').setup({
      filetypes = { "*" },
      user_default_options = {
        RGB = true, -- #RGB hex codes
        RRGGBB = true, -- #RRGGBB hex codes
        names = true, -- "Name" codes like Blue or blue
        RRGGBBAA = false, -- #RRGGBBAA hex codes
        AARRGGBB = false, -- 0xAARRGGBB hex codes
        rgb_fn = false, -- CSS rgb() and rgba() functions
        hsl_fn = false, -- CSS hsl() and hsla() functions
        css = false, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        css_fn = false, -- Enable all CSS *functions*: rgb_fn, hsl_fn
        mode = "background", -- Set the display mode.
        tailwind = false, -- Enable tailwind colors
        sass = { enable = false, parsers = { "css" }, }, -- Enable sass colors
        virtualtext = "■",
      },
      buftypes = {},
    })
  end

  -- 9. Auto-pair brackets/quotes (passive)
  if pcall(require, 'nvim-autopairs') then
    require('nvim-autopairs').setup({
      check_ts = true,
      ts_config = {
        lua = {'string'},-- it will not add a pair on that treesitter node
        javascript = {'template_string'},
        java = false,-- don't check treesitter on java
      }
    })
  end

  -- 10. Enhanced f/F/t/T motions (passive enhancement)
  if pcall(require, 'hop') then
    require('hop').setup()
    -- Simple keybindings for hopping around
    vim.keymap.set('n', 'f', "<cmd>HopChar1CurrentLineAC<cr>", {desc = "Hop forward to char"})
    vim.keymap.set('n', 'F', "<cmd>HopChar1CurrentLineBC<cr>", {desc = "Hop backward to char"})
  end

end

return M
