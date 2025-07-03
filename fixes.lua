-- lua/fixes.lua
-- Run this to fix common compatibility issues

local M = {}

function M.setup()
-- Fix deprecated LSP API warnings
if vim.lsp.get_active_clients then
    -- Alias for backward compatibility
    vim.lsp.get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients
    end

    -- Suppress common deprecation warnings during startup
    local original_notify = vim.notify
    vim.notify = function(msg, level, opts)
    -- Filter out specific deprecation warnings during startup
    if type(msg) == "string" and msg:match("get_active_clients.*deprecated") then
        return
        end
        return original_notify(msg, level, opts)
        end

        -- Restore normal notifications after startup
        vim.defer_fn(function()
        vim.notify = original_notify
        end, 2000)

        -- Ensure which-key is loaded properly
        local ok, wk = pcall(require, "which-key")
        if not ok then
            vim.notify("which-key not found - install it for better keybinding hints", vim.log.levels.WARN)
            return
            end

            -- Ensure nvim-tree is loaded properly
            local tree_ok, _ = pcall(require, "nvim-tree")
            if not tree_ok then
                vim.notify("nvim-tree not found - install it for file explorer", vim.log.levels.WARN)
                end

                -- Set up better error handling for missing plugins
                local function safe_require(module)
                local ok, result = pcall(require, module)
                if not ok then
                    vim.notify("Plugin " .. module .. " not found - some features may not work", vim.log.levels.WARN)
                    return nil
                    end
                    return result
                    end

                    -- Export safe_require for other modules
                    _G.safe_require = safe_require
                    end

                    return M
