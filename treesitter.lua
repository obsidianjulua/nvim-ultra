-- lua/treesitter.lua

-- Guard clause to prevent double loading
if vim.g.loaded_nvim_treesitter then
  return
  end
  vim.g.loaded_nvim_treesitter = true

  -- Setup nvim-treesitter configuration
  require('nvim-treesitter.configs').setup {
    -- A list of parser names, or "all"
    ensure_installed = {
      "julia", "lua", "markdown", "markdown_inline",
      "python", "javascript", "typescript", "html", "css",
      "json", "yaml", "toml", "bash", "vim", "vimdoc",
      "c", "cpp", "rust", "go", "java", "sql", "dockerfile",
      "git_config", "git_rebase", "gitcommit", "gitignore"
    },

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- Automatically install missing parsers when entering buffer
    auto_install = true,

    -- List of parsers to ignore installing (for "all")
    ignore_install = {},

    highlight = {
      enable = true,
      -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
      -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
      -- Using this option may slow down your editor, and you may see some duplicate highlights.
      -- Instead of true it can also be a list of languages
      additional_vim_regex_highlighting = false,
      -- Disable highlighting for large files
      disable = function(lang, buf)
      local max_filesize = 100 * 1024 -- 100 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
        end
        end,
    },

    indent = {
      enable = true,
      -- Disable for specific languages if needed
      disable = { "python" }, -- Python indentation can be tricky with treesitter
    },

    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "gnn",
        node_incremental = "grn",
        scope_incremental = "grc",
        node_decremental = "grm",
      },
    },

    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
          ["aa"] = "@parameter.outer",
          ["ia"] = "@parameter.inner",
          ["al"] = "@loop.outer",
          ["il"] = "@loop.inner",
          ["ai"] = "@conditional.outer",
          ["ii"] = "@conditional.inner",
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          ["]f"] = "@function.outer",
          ["]c"] = "@class.outer",
          ["]a"] = "@parameter.inner",
        },
        goto_next_end = {
          ["]F"] = "@function.outer",
          ["]C"] = "@class.outer",
          ["]A"] = "@parameter.inner",
        },
        goto_previous_start = {
          ["[f"] = "@function.outer",
          ["[c"] = "@class.outer",
          ["[a"] = "@parameter.inner",
        },
        goto_previous_end = {
          ["[F"] = "@function.outer",
          ["[C"] = "@class.outer",
          ["[A"] = "@parameter.inner",
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ["<leader>a"] = "@parameter.inner",
        },
        swap_previous = {
          ["<leader>A"] = "@parameter.inner",
        },
      },
    },

    -- Enable folding based on treesitter
    fold = {
      enable = true,
      disable = {},
    },

    -- Rainbow parentheses
    rainbow = {
      enable = true,
      extended_mode = true, -- Also highlight non-bracket delimiters like html tags
      max_file_lines = nil, -- Do not enable for files with more than n lines
      colors = {
        "#cc241d",
        "#a89984",
        "#b16286",
        "#d79921",
        "#689d6a",
        "#d65d0e",
        "#458588",
      },
    },

    -- Context showing (requires nvim-treesitter-context plugin)
    context = {
      enable = true,
      max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
      min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
      line_numbers = true,
      multiline_threshold = 20, -- Maximum number of lines to collapse for a single context line
      trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
      mode = 'cursor',  -- Line used to calculate context. Choices: 'cursor', 'topline'
      separator = nil, -- Separator between context and content. Should be a single character string, like '-'.
      zindex = 20, -- The Z-index of the context window
    },

    -- Playground for debugging treesitter (requires nvim-treesitter-playground plugin)
    playground = {
      enable = true,
      disable = {},
      updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
      persist_queries = false, -- Whether the query persists across vim sessions
      keybindings = {
        toggle_query_editor = 'o',
        toggle_hl_groups = 'i',
        toggle_injected_languages = 't',
        toggle_anonymous_nodes = 'a',
        toggle_language_display = 'I',
        focus_language = 'f',
        unfocus_language = 'F',
        update = 'R',
        goto_node = '<cr>',
        show_help = '?',
      },
    },
  }

  -- Enable treesitter-based folding
  vim.opt.foldmethod = "expr"
  vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
  vim.opt.foldenable = false -- Don't fold by default

  local api = vim.api

  -- Define autocommands for query file handling
  local augroup = api.nvim_create_augroup("NvimTreesitter", {})

  api.nvim_create_autocmd("Filetype", {
    pattern = "query",
    group = augroup,
    callback = function()
    api.nvim_clear_autocmds {
      group = augroup,
      event = "BufWritePost",
    }
    api.nvim_create_autocmd("BufWritePost", {
      group = augroup,
      buffer = 0,
      callback = function(opts)
      require("nvim-treesitter.query").invalidate_query_file(opts.file)
      end,
      desc = "Invalidate query file",
    })
    end,
    desc = "Reload query",
  })

  --[[
  Additional plugins you might want to install for enhanced functionality:

  1. nvim-treesitter-textobjects:
  Plug 'nvim-treesitter/nvim-treesitter-textobjects'

  2. nvim-treesitter-context (shows current function/class at top):
  Plug 'nvim-treesitter/nvim-treesitter-context'

  3. nvim-treesitter-playground (debugging treesitter):
  Plug 'nvim-treesitter/playground'

  4. Rainbow parentheses:
  Plug 'p00f/nvim-ts-rainbow'

  5. Auto-pairing with treesitter:
  Plug 'windwp/nvim-autopairs'

  Example keybindings you might want to add:
  vim.keymap.set('n', '<leader>tp', ':TSPlaygroundToggle<CR>', { desc = 'Toggle Treesitter Playground' })
  vim.keymap.set('n', '<leader>th', ':TSHighlightCapturesUnderCursor<CR>', { desc = 'Show TS highlight groups' })
  --]]
