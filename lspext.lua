

local M = {}

function M.setup(cmp, luasnip)
  -- 1. General LSP settings and capabilities
  -----------------------------------------------------------------
  
  -- Get the default capabilities from nvim-cmp
  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  
  -- Enable additional capabilities
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { "documentation", "detail", "additionalTextEdits" }
  }
  
  local lspconfig = require('lspconfig')
  
  -- 2. LSP Keybindings and on_attach function
  -----------------------------------------------------------------
  
  local on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    
    -- LSP Keybindings
    local opts = { noremap = true, silent = true, buffer = bufnr }
    
    -- Navigation
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)
    
    -- Documentation and help
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, opts)
    
    -- Workspace management
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    
    -- Code actions and refactoring
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('v', '<leader>ca', vim.lsp.buf.code_action, opts)
    
    -- Formatting
    vim.keymap.set('n', '<leader>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
    vim.keymap.set('v', '<leader>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
    
    -- Diagnostics
    vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)
    
    -- Telescope LSP integration (if available)
    local has_telescope, telescope = pcall(require, 'telescope.builtin')
    if has_telescope then
      vim.keymap.set('n', '<leader>lr', telescope.lsp_references, opts)
      vim.keymap.set('n', '<leader>ld', telescope.lsp_definitions, opts)
      vim.keymap.set('n', '<leader>li', telescope.lsp_implementations, opts)
      vim.keymap.set('n', '<leader>lt', telescope.lsp_type_definitions, opts)
      vim.keymap.set('n', '<leader>ls', telescope.lsp_document_symbols, opts)
      vim.keymap.set('n', '<leader>lw', telescope.lsp_workspace_symbols, opts)
      vim.keymap.set('n', '<leader>lc', telescope.lsp_incoming_calls, opts)
      vim.keymap.set('n', '<leader>lo', telescope.lsp_outgoing_calls, opts)
    end
    
    -- Format on save for specific filetypes
    if client.supports_method("textDocument/formatting") then
      local format_augroup = vim.api.nvim_create_augroup("LspFormatting", {})
      vim.api.nvim_clear_autocmds({ group = format_augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = format_augroup,
        buffer = bufnr,
        callback = function()
          -- Only format for specific filetypes
          local ft = vim.bo[bufnr].filetype
          if vim.tbl_contains({"lua", "python", "javascript", "typescript", "rust", "go"}, ft) then
            vim.lsp.buf.format({ bufnr = bufnr, async = false })
          end
        end,
      })
    end
    
    -- Highlight symbol under cursor
    if client.supports_method("textDocument/documentHighlight") then
      local highlight_augroup = vim.api.nvim_create_augroup("LspDocumentHighlight", {})
      vim.api.nvim_clear_autocmds({ group = highlight_augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        group = highlight_augroup,
        buffer = bufnr,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd("CursorMoved", {
        group = highlight_augroup,
        buffer = bufnr,
        callback = vim.lsp.buf.clear_references,
      })
    end
  end
  
  -- 3. Diagnostic Configuration
  -----------------------------------------------------------------
  
  vim.diagnostic.config({
    virtual_text = {
      enabled = true,
      source = "if_many",
      prefix = "●",
    },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
      focusable = false,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  })
  
  -- Diagnostic signs
  local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end
  
  -- 4. Language Server Configurations
  -----------------------------------------------------------------
  
  -- Julia Language Server
  lspconfig.julials.setup{
    on_attach = on_attach,
    capabilities = capabilities,
    -- Auto-detect Julia installation
    cmd = function()
      local julia_cmd = vim.fn.exepath("julia")
      if julia_cmd == "" then
        vim.notify("Julia not found in PATH", vim.log.levels.ERROR)
        return nil
      end
      return {
        julia_cmd,
        "--startup-file=no",
        "--history-file=no",
        "-e",
        "using LanguageServer; runserver()"
      }
    end,
    settings = {
      julia = {
        format = {
          indents = 4,
        },
        lint = {
          missingrefs = "all",
          iter = true,
          lazy = true,
          modname = true,
        },
      },
    },
  }
  
  -- Lua Language Server
  lspconfig.lua_ls.setup{
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
          path = vim.split(package.path, ';'),
        },
        diagnostics = {
          globals = {'vim', 'use', 'describe', 'it', 'assert', 'stub'},
        },
        workspace = {
          library = {
            vim.env.VIMRUNTIME,
            "${3rd}/luv/library",
            "${3rd}/busted/library",
          },
          checkThirdParty = false,
        },
        telemetry = {
          enable = false,
        },
        format = {
          enable = true,
          defaultConfig = {
            indent_style = "space",
            indent_size = "2",
          }
        },
      },
    },
  }
  
  -- Python Language Servers
  lspconfig.pyright.setup{
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          diagnosticMode = "workspace",
          useLibraryCodeForTypes = true,
          typeCheckingMode = "basic",
        },
      },
    },
  }
  
  -- TypeScript/JavaScript
  lspconfig.ts_ls.setup{
    on_attach = on_attach,
    capabilities = capabilities,
    init_options = {
      preferences = {
        disableSuggestions = false,
      },
    },
  }
  
  -- Rust Analyzer
  lspconfig.rust_analyzer.setup{
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
      ["rust-analyzer"] = {
        cargo = {
          allFeatures = true,
        },
        checkOnSave = {
          command = "clippy",
        },
      },
    },
  }
  
  -- Go Language Server
  lspconfig.gopls.setup{
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
      gopls = {
        analyses = {
          unusedparams = true,
        },
        staticcheck = true,
        gofumpt = true,
      },
    },
  }
  
  -- C/C++ (clangd)
  lspconfig.clangd.setup{
    on_attach = on_attach,
    capabilities = capabilities,
    cmd = {
      "clangd",
      "--background-index",
      "--clang-tidy",
      "--header-insertion=iwyu",
      "--completion-style=detailed",
      "--function-arg-placeholders",
      "--fallback-style=llvm",
    },
  }
  
  -- JSON Language Server
  lspconfig.jsonls.setup{
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
      json = {
        schemas = require('schemastore').json.schemas(),
        validate = { enable = true },
      },
    },
  }
  
  -- YAML Language Server
  lspconfig.yamlls.setup{
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
      yaml = {
        schemaStore = {
          enable = false,
          url = "",
        },
        schemas = require('schemastore').yaml.schemas(),
      },
    },
  }
  
  -- HTML Language Server
  lspconfig.html.setup{
    on_attach = on_attach,
    capabilities = capabilities,
  }
  
  -- CSS Language Server
  lspconfig.cssls.setup{
    on_attach = on_attach,
    capabilities = capabilities,
  }
  
  -- Bash Language Server
  lspconfig.bashls.setup{
    on_attach = on_attach,
    capabilities = capabilities,
  }
  
  -- Docker Language Server
  lspconfig.dockerls.setup{
    on_attach = on_attach,
    capabilities = capabilities,
  }
  
  -- 5. nvim-cmp (Completion) Configuration
  -----------------------------------------------------------------
  
  cmp.setup({
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    formatting = {
      format = function(entry, vim_item)
        -- Kind icons
        local icons = {
          Text = "",
          Method = "󰆧",
          Function = "󰊕",
          Constructor = "",
          Field = "󰇽",
          Variable = "󰂡",
          Class = "󰠱",
          Interface = "",
          Module = "",
          Property = "󰜢",
          Unit = "",
          Value = "󰎠",
          Enum = "",
          Keyword = "󰌋",
          Snippet = "",
          Color = "󰏘",
          File = "󰈙",
          Reference = "",
          Folder = "󰉋",
          EnumMember = "",
          Constant = "󰏿",
          Struct = "",
          Event = "",
          Operator = "󰆕",
          TypeParameter = "󰅲",
        }
        
        vim_item.kind = string.format('%s %s', icons[vim_item.kind], vim_item.kind)
        vim_item.menu = ({
          copilot_cmp = "[Copilot]",
          nvim_lsp = "[LSP]",
          luasnip = "[LuaSnip]",
          buffer = "[Buffer]",
          path = "[Path]",
          cmdline = "[CMD]",
        })[entry.source.name]
        
        return vim_item
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ 
        behavior = cmp.ConfirmBehavior.Replace,
        select = true 
      }),
      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { "i", "s" }),
      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),
    }),
    sources = cmp.config.sources({
      { name = 'copilot_cmp', group_index = 2 },
      { name = 'nvim_lsp', group_index = 2 },
      { name = 'luasnip', group_index = 2 },
      { name = 'path', group_index = 2 },
    }, {
      { name = 'buffer', group_index = 3 },
    })
  })
  
  -- Command line completion
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
    })
  })
  
  -- 6. Additional LSP Enhancements
  -----------------------------------------------------------------
  
  -- Show line diagnostics automatically in hover window
  vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
      local opts = {
        focusable = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        border = 'rounded',
        source = 'always',
        prefix = ' ',
        scope = 'cursor',
      }
      vim.diagnostic.open_float(nil, opts)
    end
  })
  
  -- Global LSP keybindings (not buffer-specific)
  vim.keymap.set('n', '<leader>lI', '<cmd>LspInfo<cr>', { desc = 'LSP Info' })
  vim.keymap.set('n', '<leader>lR', '<cmd>LspRestart<cr>', { desc = 'LSP Restart' })
  
end

return M
