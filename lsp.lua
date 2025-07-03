-- lua/lsp.lua

local M = {}

function M.setup(cmp, luasnip)
-- Get capabilities from nvim-cmp
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local lspconfig = require('lspconfig')

-- Simple on_attach with only essential keybindings
local on_attach = function(client, bufnr)
vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

-- Only the most essential keybindings
local opts = { noremap = true, silent = true, buffer = bufnr }
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)           -- Go to definition
vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)                -- Show docs on hover
vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, opts)       -- Rename symbol
vim.keymap.set('n', '<leader>a', vim.lsp.buf.code_action, opts)  -- Code actions

-- Auto-format on save (passive)
if client.supports_method("textDocument/formatting") then
  vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = bufnr,
    callback = function()
    vim.lsp.buf.format({ bufnr = bufnr, async = false })
    end,
  })
  end

  -- Auto-highlight symbol under cursor (passive)
  if client.supports_method("textDocument/documentHighlight") then
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd("CursorMoved", {
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
    end
    end

    -- Passive diagnostic display (no keybindings needed)
    vim.diagnostic.config({
      virtual_text = true,
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    })

    -- Language servers with minimal config
    lspconfig.julials.setup{
      on_attach = on_attach,
      capabilities = capabilities,
    }

    lspconfig.lua_ls.setup{
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        Lua = {
          diagnostics = { globals = {'vim'} },
          workspace = { library = vim.api.nvim_get_runtime_file("", true) },
          telemetry = { enable = false },
        },
      },
    }

    -- Add more language servers as needed with same simple pattern
    lspconfig.pyright.setup{ on_attach = on_attach, capabilities = capabilities }
    lspconfig.ts_ls.setup{ on_attach = on_attach, capabilities = capabilities }
    lspconfig.rust_analyzer.setup{ on_attach = on_attach, capabilities = capabilities }
    lspconfig.gopls.setup{ on_attach = on_attach, capabilities = capabilities }
    lspconfig.clangd.setup{ on_attach = on_attach, capabilities = capabilities }

    -- FULL POWER COMPLETION SETUP - All the best features restored!
    cmp.setup({
      snippet = {
        expand = function(args)
        luasnip.lsp_expand(args.body)
        end,
      },
      completion = {
        autocomplete = { 'TextChanged' }, -- Auto-trigger as you type
        completeopt = 'menu,menuone,noselect',
        keyword_length = 1, -- Start completing after 1 character
      },
      window = {
        completion = cmp.config.window.bordered({
          border = 'rounded',
          winhighlight = 'Normal:CmpPmenu,CursorLine:CmpSel,Search:None',
        }),
        documentation = cmp.config.window.bordered({
          border = 'rounded',
          winhighlight = 'Normal:CmpDoc',
        }),
      },
      formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
          -- Kind icons for MAXIMUM visual appeal
          local icons = {
            Text = " ",
            Method = " ",
            Function = " ",
            Constructor = " ",
            Field = " ",
            Variable = " ",
            Class = " ",
            Interface = " ",
            Module = " ",
            Property = " ",
            Unit = " ",
            Value = " ",
            Enum = " ",
            Keyword = " ",
            Snippet = " ",
            Color = " ",
            File = " ",
            Reference = " ",
            Folder = " ",
            EnumMember = " ",
            Constant = " ",
            Struct = " ",
            Event = " ",
            Operator = " ",
            TypeParameter = " ",
          }

          -- Apply icon and formatting
          vim_item.kind = string.format('%s %s', icons[vim_item.kind] or " ", vim_item.kind)

          -- Enhanced source indicators with colors
          vim_item.menu = ({
            nvim_lsp = "[LSP]",
            copilot_cmp = "[Copilot]",
            luasnip = "[Snippet]",
            buffer = "[Buffer]",
            path = "[Path]",
            cmdline = "[CMD]",
            nvim_lua = "[Lua]",
            treesitter = "[TS]",
          })[entry.source.name]

          -- Truncate long completions but keep them readable
          local max_width = 50
          if string.len(vim_item.abbr) > max_width then
            vim_item.abbr = string.sub(vim_item.abbr, 1, max_width - 3) .. "..."
            end

            return vim_item
            end,
      },
      mapping = {
        -- Your simple Space trigger (keep this!)
    ['<Space>'] = cmp.mapping(function(fallback)
    if not cmp.visible() then
      cmp.complete()
      else
        fallback()
        end
        end, { "i" }),

        -- Advanced navigation and control
        ['<C-Space>'] = cmp.mapping.complete(),
              ['<C-b>'] = cmp.mapping.scroll_docs(-4),
              ['<C-f>'] = cmp.mapping.scroll_docs(4),
              ['<C-e>'] = cmp.mapping.abort(),

              ['<Tab>'] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
                elseif luasnip.expand_or_jumpable() then
                  luasnip.expand_or_jump()
                  else
                    fallback()
                    end
                    end, { "i", "s" }),

              ['<S-Tab>'] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
                elseif luasnip.jumpable(-1) then
                  luasnip.jump(-1)
                  else
                    fallback()
                    end
                    end, { "i", "s" }),

              ['<CR>'] = cmp.mapping({
                i = function(fallback)
                if cmp.visible() and cmp.get_active_entry() then
                  cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
                  else
                    fallback()
                    end
                    end,
                    s = cmp.mapping.confirm({ select = true }),
                                     c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
              }),
      },
      sources = cmp.config.sources({
        {
          name = 'nvim_lsp',
          priority = 1000,
          entry_filter = function(entry, ctx)
          -- Filter out text completions from LSP
          return entry:get_kind() ~= cmp.lsp.CompletionItemKind.Text
          end,
        },
        { name = 'copilot_cmp', priority = 900, group_index = 2 },
        { name = 'luasnip', priority = 800 },
        { name = 'nvim_lua', priority = 700 },
        { name = 'path', priority = 600 },
        { name = 'treesitter', priority = 500 },
      }, {
        { name = 'buffer', priority = 400, keyword_length = 3 },
        { name = 'spell', priority = 300 },
      }),
      experimental = {
        ghost_text = {
          hl_group = "CmpGhostText",
        },
      },
      performance = {
        debounce = 60,
        throttle = 30,
        fetching_timeout = 500,
        confirm_resolve_timeout = 80,
        async_budget = 1,
        max_view_entries = 200,
      },
    })

    -- Enhanced command line completion
    cmp.setup.cmdline({ '/', '?' }, {
      mapping = cmp.mapping.preset.cmdline(),
                      sources = {
                        { name = 'buffer' }
                      }
    })

    cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline(),
                      sources = cmp.config.sources({
                        { name = 'path' }
                      }, {
                        { name = 'cmdline' }
                      }),
                      matching = { disallow_symbol_nonprefix_matching = false }
    })

    -- Filetype-specific completions
    cmp.setup.filetype('gitcommit', {
      sources = cmp.config.sources({
        { name = 'buffer' },
      })
    })

    -- Enhanced Lua completion for config files
    cmp.setup.filetype('lua', {
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'nvim_lua' },
        { name = 'luasnip' },
        { name = 'buffer' },
        { name = 'path' }
      })
    })
    end

    return M
