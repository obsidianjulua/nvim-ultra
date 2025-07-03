-- lua/build.lua - Focused build system for Lua, Julia, and CMake
local M = {}

-- Build configurations
local build_configs = {
    julia = {
        run = "julia %",
        test = "julia --project=. -e 'using Pkg; Pkg.test()'",
        build = "julia --project=. -e 'using Pkg; Pkg.instantiate()'",
        update = "julia --project=. -e 'using Pkg; Pkg.update()'",
        repl = "julia",
    },
    lua = {
        run = "lua %",
        test = "busted . || echo 'No busted tests found'",
        build = "luarocks install --local --only-deps . || echo 'No rockspec found'",
        repl = "lua",
    },
    cmake = {
        configure = "cmake -B build -S .",
        build = "cmake --build build",
        clean = "rm -rf build",
        install = "cmake --install build",
        test = "cd build && ctest",
    },
}

-- Output buffer state
local output_buf = nil
local output_win = nil

local function create_output_window()
if not output_buf or not vim.api.nvim_buf_is_valid(output_buf) then
    output_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(output_buf, "[Build Output]")
    vim.bo[output_buf].buftype = "nofile"
    vim.bo[output_buf].swapfile = false
    vim.bo[output_buf].modifiable = false
    end

    vim.cmd("botright split")
    output_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(output_win, output_buf)
    vim.api.nvim_win_set_height(output_win, 12)

    vim.wo[output_win].number = false
    vim.wo[output_win].relativenumber = false
    vim.wo[output_win].wrap = true
    vim.wo[output_win].cursorline = true

    return output_buf, output_win
    end

    local function append_to_output(data)
    if not output_buf or not vim.api.nvim_buf_is_valid(output_buf) then
        return
        end

        vim.bo[output_buf].modifiable = true

        local lines = {}
        if type(data) == "table" then
            for _, line in ipairs(data) do
                if line and line ~= "" then
                    table.insert(lines, line)
                    end
                    end
                    else
                        table.insert(lines, tostring(data))
                        end

                        if #lines > 0 then
                            vim.api.nvim_buf_set_lines(output_buf, -1, -1, false, lines)
                            if output_win and vim.api.nvim_win_is_valid(output_win) then
                                local line_count = vim.api.nvim_buf_line_count(output_buf)
                                vim.api.nvim_win_set_cursor(output_win, {line_count, 0})
                                end
                                end

                                vim.bo[output_buf].modifiable = false
                                end

                                local function clear_output()
                                if output_buf and vim.api.nvim_buf_is_valid(output_buf) then
                                    vim.bo[output_buf].modifiable = true
                                    vim.api.nvim_buf_set_lines(output_buf, 0, -1, false, {})
                                    vim.bo[output_buf].modifiable = false
                                    end
                                    end

                                    local function get_project_root()
                                    local markers = {
                                        "Project.toml",     -- Julia
                                        "CMakeLists.txt",   -- CMake
                                        ".git",
                                    }

                                    local current_dir = vim.fn.expand("%:p:h")

                                    while current_dir ~= "/" do
                                        for _, marker in ipairs(markers) do
                                            local path = current_dir .. "/" .. marker
                                            if vim.fn.filereadable(path) == 1 or vim.fn.isdirectory(path) == 1 then
                                                return current_dir
                                                end
                                                end

                                                -- Check for .rockspec files
                                                local rockspecs = vim.fn.glob(current_dir .. "/*.rockspec", false, true)
                                                if #rockspecs > 0 then
                                                    return current_dir
                                                    end

                                                    current_dir = vim.fn.fnamemodify(current_dir, ":h")
                                                    end

                                                    return vim.fn.expand("%:p:h")
                                                    end

                                                    local function run_command(cmd, action_name)
                                                    if not cmd then
                                                        vim.notify("No " .. action_name .. " command configured", vim.log.levels.WARN)
                                                        return
                                                        end

                                                        create_output_window()
                                                        clear_output()

                                                        local timestamp = os.date("%H:%M:%S")
                                                        append_to_output({
                                                            "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
                                                            string.format("🚀 %s - %s", action_name:upper(), timestamp),
                                                                         string.format("📁 %s", get_project_root()),
                                                                         string.format("⚡ %s", cmd),
                                                                         "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
                                                                         "",
                                                        })

                                                        local current_win = vim.api.nvim_get_current_win()

                                                        local job_id = vim.fn.jobstart(cmd, {
                                                            cwd = get_project_root(),
                                                                                       stdout_buffered = false,
                                                                                       stderr_buffered = false,
                                                                                       on_stdout = function(_, data, _) append_to_output(data) end,
                                                                                       on_stderr = function(_, data, _) append_to_output(data) end,
                                                                                       on_exit = function(_, exit_code, _)
                                                                                       local status = exit_code == 0 and "✅ SUCCESS" or "❌ FAILED"
                                                                                       local end_time = os.date("%H:%M:%S")
                                                                                       append_to_output({
                                                                                           "",
                                                                                           "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
                                                                                           string.format("%s - Exit code: %d - %s", status, exit_code, end_time),
                                                                                                        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
                                                                                       })

                                                                                       local level = exit_code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
                                                                                       vim.notify(string.format("%s %s", action_name, status), level)

                                                                                       vim.defer_fn(function()
                                                                                       if vim.api.nvim_win_is_valid(current_win) then
                                                                                           vim.api.nvim_set_current_win(current_win)
                                                                                           end
                                                                                           end, 500)
                                                                                       end,
                                                        })

                                                        if job_id <= 0 then
                                                            append_to_output({"❌ Failed to start job"})
                                                            vim.notify("Failed to start " .. action_name, vim.log.levels.ERROR)
                                                            end
                                                            end

                                                            local function detect_project_type()
                                                            local root = get_project_root()

                                                            if vim.fn.filereadable(root .. "/CMakeLists.txt") == 1 then
                                                                return "cmake"
                                                                elseif vim.fn.filereadable(root .. "/Project.toml") == 1 then
                                                                    return "julia"
                                                                    elseif #vim.fn.glob(root .. "/*.rockspec", false, true) > 0 then
                                                                        return "lua"
                                                                        else
                                                                            return vim.bo.filetype
                                                                            end
                                                                            end

                                                                            -- Main functions
                                                                            function M.run()
                                                                            local project_type = detect_project_type()
                                                                            local config = build_configs[project_type]

                                                                            if config and config.run then
                                                                                run_command(config.run, "run")
                                                                                else
                                                                                    vim.notify("No run command for: " .. project_type, vim.log.levels.WARN)
                                                                                    end
                                                                                    end

                                                                                    function M.test()
                                                                                    local project_type = detect_project_type()
                                                                                    local config = build_configs[project_type]

                                                                                    if config and config.test then
                                                                                        run_command(config.test, "test")
                                                                                        else
                                                                                            vim.notify("No test command for: " .. project_type, vim.log.levels.WARN)
                                                                                            end
                                                                                            end

                                                                                            function M.build()
                                                                                            local project_type = detect_project_type()
                                                                                            local config = build_configs[project_type]

                                                                                            if project_type == "cmake" then
                                                                                                if vim.fn.isdirectory("build") == 0 then
                                                                                                    run_command(config.configure, "configure")
                                                                                                    vim.defer_fn(function()
                                                                                                    run_command(config.build, "build")
                                                                                                    end, 1000)
                                                                                                    else
                                                                                                        run_command(config.build, "build")
                                                                                                        end
                                                                                                        elseif config and config.build then
                                                                                                            run_command(config.build, "build")
                                                                                                            else
                                                                                                                vim.notify("No build command for: " .. project_type, vim.log.levels.WARN)
                                                                                                                end
                                                                                                                end

                                                                                                                function M.clean()
                                                                                                                local project_type = detect_project_type()
                                                                                                                local config = build_configs[project_type]

                                                                                                                if project_type == "cmake" and config.clean then
                                                                                                                    run_command(config.clean, "clean")
                                                                                                                    else
                                                                                                                        vim.notify("Clean only available for CMake projects", vim.log.levels.WARN)
                                                                                                                        end
                                                                                                                        end

                                                                                                                        function M.configure()
                                                                                                                        local project_type = detect_project_type()

                                                                                                                        if project_type == "cmake" then
                                                                                                                            run_command(build_configs.cmake.configure, "configure")
                                                                                                                            elseif project_type == "julia" then
                                                                                                                                run_command(build_configs.julia.update, "update packages")
                                                                                                                                else
                                                                                                                                    vim.notify("Configure not available for: " .. project_type, vim.log.levels.WARN)
                                                                                                                                    end
                                                                                                                                    end

                                                                                                                                    function M.repl()
                                                                                                                                    local project_type = detect_project_type()
                                                                                                                                    local config = build_configs[project_type]

                                                                                                                                    if config and config.repl then
                                                                                                                                        vim.cmd("botright split")
                                                                                                                                        vim.cmd("terminal " .. config.repl)
                                                                                                                                        vim.cmd("startinsert")
                                                                                                                                        else
                                                                                                                                            vim.notify("No REPL for: " .. project_type, vim.log.levels.WARN)
                                                                                                                                            end
                                                                                                                                            end

                                                                                                                                            function M.close_output()
                                                                                                                                            if output_win and vim.api.nvim_win_is_valid(output_win) then
                                                                                                                                                vim.api.nvim_win_close(output_win, false)
                                                                                                                                                output_win = nil
                                                                                                                                                end
                                                                                                                                                end

                                                                                                                                                function M.toggle_output()
                                                                                                                                                if output_win and vim.api.nvim_win_is_valid(output_win) then
                                                                                                                                                    M.close_output()
                                                                                                                                                    else
                                                                                                                                                        if output_buf and vim.api.nvim_buf_is_valid(output_buf) then
                                                                                                                                                            create_output_window()
                                                                                                                                                            else
                                                                                                                                                                vim.notify("No build output to show", vim.log.levels.INFO)
                                                                                                                                                                end
                                                                                                                                                                end
                                                                                                                                                                end

                                                                                                                                                                function M.setup()
                                                                                                                                                                -- Keybindings
                                                                                                                                                                vim.keymap.set('n', '<leader>br', M.run, { desc = 'Build: Run current file' })
                                                                                                                                                                vim.keymap.set('n', '<leader>bt', M.test, { desc = 'Build: Run tests' })
                                                                                                                                                                vim.keymap.set('n', '<leader>bb', M.build, { desc = 'Build: Build project' })
                                                                                                                                                                vim.keymap.set('n', '<leader>bc', M.configure, { desc = 'Build: Configure/Update' })
                                                                                                                                                                vim.keymap.set('n', '<leader>bo', M.toggle_output, { desc = 'Build: Toggle output' })
                                                                                                                                                                vim.keymap.set('n', '<leader>R', M.repl, { desc = 'Open REPL' })

                                                                                                                                                                -- Auto-close output with 'q'
                                                                                                                                                                vim.api.nvim_create_autocmd("FileType", {
                                                                                                                                                                    pattern = "nofile",
                                                                                                                                                                    callback = function()
                                                                                                                                                                    if vim.api.nvim_buf_get_name(0):match("%[Build Output%]") then
                                                                                                                                                                        vim.keymap.set('n', 'q', M.close_output, { buffer = true, silent = true })
                                                                                                                                                                        end
                                                                                                                                                                        end,
                                                                                                                                                                })

                                                                                                                                                                -- Auto-save before building
                                                                                                                                                                vim.api.nvim_create_autocmd("User", {
                                                                                                                                                                    pattern = "BuildStart",
                                                                                                                                                                    callback = function()
                                                                                                                                                                    if vim.bo.modified then
                                                                                                                                                                        vim.cmd("silent write")
                                                                                                                                                                        end
                                                                                                                                                                        end,
                                                                                                                                                                })
                                                                                                                                                                end

                                                                                                                                                                return M
