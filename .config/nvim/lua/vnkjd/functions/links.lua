local M = {}

local url_pattern = "[%a][%w+.-]*://[^%s<>'\"`]+"
local www_pattern = "www%.[^%s<>'\"`]+"

local function normalize_url(url)
    url = url:gsub("^[%s<('\"`]+", "")
    url = url:gsub("[%s>,'\"`]+$", "")

    while url:sub(-1) == "." or url:sub(-1) == "," or url:sub(-1) == ";"
        or url:sub(-1) == ":"
        or url:sub(-1) == "!"
        or url:sub(-1) == "?"
    do
        url = url:sub(1, -2)
    end

    while url:sub(-1) == ")" do
        local opens = select(2, url:gsub("%(", ""))
        local closes = select(2, url:gsub("%)", ""))

        if closes <= opens then
            break
        end

        url = url:sub(1, -2)
    end

    if url:match "^www%." then
        url = "https://" .. url
    end

    return url
end

local function find_url_in_text(text, cursor_col)
    for _, pattern in ipairs { url_pattern, www_pattern } do
        local start_col = 1

        while true do
            local match_start, match_end = text:find(pattern, start_col)
            if match_start == nil then
                break
            end

            if cursor_col == nil or (cursor_col >= match_start and cursor_col <= match_end) then
                return normalize_url(text:sub(match_start, match_end))
            end

            start_col = match_end + 1
        end
    end

    return nil
end

local function get_visual_text()
    local start_pos = vim.fn.getpos "'<"
    local end_pos = vim.fn.getpos "'>"
    local start_row = start_pos[2]
    local start_col = start_pos[3]
    local end_row = end_pos[2]
    local end_col = end_pos[3]

    if start_row == 0 or end_row == 0 then
        return ""
    end

    if start_row > end_row or (start_row == end_row and start_col > end_col) then
        start_row, end_row = end_row, start_row
        start_col, end_col = end_col, start_col
    end

    local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
    if #lines == 0 then
        return ""
    end

    lines[#lines] = lines[#lines]:sub(1, end_col)
    lines[1] = lines[1]:sub(start_col)

    return table.concat(lines, "\n")
end

function M.find_url_under_cursor()
    local line = vim.api.nvim_get_current_line()
    local cursor_col = vim.api.nvim_win_get_cursor(0)[2] + 1

    return find_url_in_text(line, cursor_col)
end

function M.find_url_in_visual_selection()
    return find_url_in_text(get_visual_text())
end

function M.open(url)
    if url == nil or url == "" then
        vim.notify("link: no URL found", vim.log.levels.WARN)
        return
    end

    if vim.ui.open ~= nil then
        vim.ui.open(url)
        return
    end

    local opener
    if vim.fn.executable "xdg-open" == 1 then
        opener = "xdg-open"
    elseif vim.fn.executable "open" == 1 then
        opener = "open"
    elseif vim.fn.executable "wslview" == 1 then
        opener = "wslview"
    end

    if opener == nil then
        vim.notify("link: no opener found", vim.log.levels.ERROR)
        return
    end

    vim.fn.jobstart({ opener, url }, { detach = true })
end

function M.open_under_cursor()
    M.open(M.find_url_under_cursor())
end

function M.open_visual_selection()
    M.open(M.find_url_in_visual_selection())
end

M._find_url_in_text = find_url_in_text

return M
