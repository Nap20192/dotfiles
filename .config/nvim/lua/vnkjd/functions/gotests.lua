local ts = require "vnkjd.functions.treesitter"
local M = {}

-- Walk up the AST looking for function_declaration or method_declaration and
-- return the function name.  method_declaration uses field_identifier for its
-- name, function_declaration uses identifier — both live in the "name" field,
-- so get_node_field_text works for both.  This is why treesitter beats <cword>:
-- when the cursor is inside the body (not on the name token) <cword> gives
-- whatever word is under the cursor; and for a method like
--   func (s *Server) Handle(...)
-- <cword> on the receiver gives "s", not "Handle".
local function get_func_name()
    return ts.find_enclosing_node(function(node)
        local t = node:type()
        if t == "function_declaration" or t == "method_declaration" then
            return ts.get_node_field_text(node, "name")
        end
    end)
end

-- Open or switch to the test file, returning the window id.
local function open_test_file(test_file)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.api.nvim_buf_get_name(buf) == test_file then
            vim.api.nvim_set_current_win(win)
            return win
        end
    end
    vim.cmd("vsplit " .. vim.fn.fnameescape(test_file))
    return vim.api.nvim_get_current_win()
end

-- After gotests writes the file, find the TODO line and position the cursor.
local function jump_to_todo(test_file, func_name)
    local buf = vim.fn.bufnr(test_file, true)
    vim.fn.bufload(buf)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

    -- gotests inserts "// TODO: Add test cases." inside the slice literal
    for i, line in ipairs(lines) do
        if line:find("// TODO: Add test cases.", 1, true) then
            vim.api.nvim_win_set_cursor(0, { i, 0 })
            -- delete the TODO comment and drop into insert mode at that position
            vim.cmd "normal! dd"
            vim.cmd "startinsert"
            return
        end
    end

    -- Test already existed — find the TestXxx function and jump there
    local pattern = "^func Test" .. func_name:sub(1, 1):upper() .. func_name:sub(2)
    for i, line in ipairs(lines) do
        if line:match(pattern) then
            vim.api.nvim_win_set_cursor(0, { i, 0 })
            vim.notify(
                "test for " .. func_name .. " already exists",
                vim.log.levels.INFO
            )
            return
        end
    end
end

local function run_gotests(file, func_name, on_done)
    vim.system(
        { "gotests", "-only", "^" .. func_name .. "$", "-w", file },
        { text = true },
        function(result)
            vim.schedule(function()
                on_done(result)
            end)
        end
    )
end

-- Generate a table-driven test for the function under the cursor.
function M.generate()
    if vim.fn.executable "gotests" == 0 then
        vim.notify(
            "gotests not found — install with:\n  go install github.com/cweill/gotests/gotests@latest",
            vim.log.levels.ERROR
        )
        return
    end

    local func_name = get_func_name()
    if not func_name then
        vim.notify("not inside a function", vim.log.levels.WARN)
        return
    end

    local src_file = vim.api.nvim_buf_get_name(0)
    local test_file = src_file:gsub("%.go$", "_test.go")

    run_gotests(src_file, func_name, function(result)
        if result.code ~= 0 then
            vim.notify(
                "gotests failed:\n" .. (result.stderr or ""),
                vim.log.levels.ERROR
            )
            return
        end
        open_test_file(test_file)
        vim.cmd("edit " .. vim.fn.fnameescape(test_file))
        jump_to_todo(test_file, func_name)
    end)
end

-- Generate tests for all exported functions in the current file.
function M.generate_all()
    if vim.fn.executable "gotests" == 0 then
        vim.notify(
            "gotests not found — install with:\n  go install github.com/cweill/gotests/gotests@latest",
            vim.log.levels.ERROR
        )
        return
    end

    local src_file = vim.api.nvim_buf_get_name(0)
    local test_file = src_file:gsub("%.go$", "_test.go")

    vim.system(
        { "gotests", "-all", "-w", src_file },
        { text = true },
        function(result)
            vim.schedule(function()
                if result.code ~= 0 then
                    vim.notify(
                        "gotests failed:\n" .. (result.stderr or ""),
                        vim.log.levels.ERROR
                    )
                    return
                end
                open_test_file(test_file)
                vim.cmd("edit " .. vim.fn.fnameescape(test_file))
                vim.notify("generated tests for all functions", vim.log.levels.INFO)
            end)
        end
    )
end

function M.health()
    if vim.fn.executable "gotests" == 1 then
        local result = vim.system({ "gotests", "--version" }, { text = true }):wait()
        vim.health.ok("gotests found: " .. (result.stdout or ""):gsub("\n", ""))
    else
        vim.health.error(
            "gotests not found",
            "go install github.com/cweill/gotests/gotests@latest"
        )
    end
end

return M
