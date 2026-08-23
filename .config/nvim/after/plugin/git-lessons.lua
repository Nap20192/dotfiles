-- :GitLesson [1-6] — open a git lesson in a right side panel (reuses the
-- panel window); :GitLesson with no arg opens the index.
local dir = vim.fn.stdpath("config") .. "/git-lessons/"

local function lesson_file(n)
    if not n or n == "" then
        return dir .. "README.md"
    end
    return vim.fn.glob(dir .. string.format("%02d", tonumber(n)) .. "-*.md")
end

vim.api.nvim_create_user_command("GitLesson", function(opts)
    local file = lesson_file(opts.args)
    if file == "" then
        vim.notify("no such lesson: " .. opts.args, vim.log.levels.ERROR)
        return
    end
    -- reuse an existing lesson window if one is open
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local name = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
        if name:find("git%-lessons/") then
            vim.api.nvim_set_current_win(win)
            vim.cmd.edit(file)
            return
        end
    end
    vim.cmd("vertical botright 80vsplit " .. vim.fn.fnameescape(file))
    vim.wo.wrap = true
    vim.wo.linebreak = true
    vim.wo.winfixwidth = true
end, { nargs = "?", desc = "Open git lesson in side panel" })
