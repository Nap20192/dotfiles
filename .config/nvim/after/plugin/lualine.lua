local lualine = require "lualine"

local palettes = {
    dark = {
        bg = "#080706",
        fg = "#f4efe6",
        muted = "#8a7b67",
        visual = "#ff9900",
        remove = "#652c29",
        search = "#00afff",
        cursor_text = "#18130d",
    },
    light = {
        bg = "#fffaf0",
        fg = "#18130d",
        muted = "#746653",
        visual = "#ff9900",
        remove = "#e2a298",
        search = "#00afff",
        cursor_text = "#18130d",
    },
}

local theme_state = vim.fn.expand(
    (vim.env.XDG_CACHE_HOME or "~/.cache") .. "/vnkjd/theme"
)
local mode = vim.o.background
if vim.fn.filereadable(theme_state) == 1 then
    local state = vim.trim(vim.fn.readfile(theme_state, "", 1)[1] or "")
    if state == "light" or state == "dark" then
        mode = state
    end
end

local palette = assert(palettes[mode], "unknown lualine theme mode: " .. tostring(mode))
local transparent_terminal = vim.env.KITTY_WINDOW_ID ~= nil
    or vim.env.GHOSTTY_RESOURCES_DIR ~= nil
    or vim.env.TERM == "xterm-kitty"
    or vim.env.TERM == "xterm-ghostty"
local transparent = vim.g.vnkjd_transparent_background ~= false
    and transparent_terminal
local bar_bg = transparent and "NONE" or palette.bg

local lualine_theme = {
    normal = {
        a = { fg = palette.cursor_text, bg = palette.visual, gui = "bold" },
        b = { fg = palette.fg, bg = bar_bg },
        c = { fg = palette.fg, bg = bar_bg },
    },
    insert = {
        a = { fg = palette.cursor_text, bg = palette.visual, gui = "bold" },
        b = { fg = palette.fg, bg = bar_bg },
        c = { fg = palette.fg, bg = bar_bg },
    },
    visual = {
        a = { fg = palette.cursor_text, bg = palette.visual, gui = "bold" },
        b = { fg = palette.fg, bg = bar_bg },
        c = { fg = palette.fg, bg = bar_bg },
    },
    replace = {
        a = { fg = palette.cursor_text, bg = palette.remove, gui = "bold" },
        b = { fg = palette.fg, bg = bar_bg },
        c = { fg = palette.fg, bg = bar_bg },
    },
    command = {
        a = { fg = palette.cursor_text, bg = palette.search, gui = "bold" },
        b = { fg = palette.fg, bg = bar_bg },
        c = { fg = palette.fg, bg = bar_bg },
    },
    inactive = {
        a = { fg = palette.muted, bg = bar_bg },
        b = { fg = palette.muted, bg = bar_bg },
        c = { fg = palette.muted, bg = bar_bg },
    },
}

local function is_jdtls_buffer()
    local buf_path = vim.fn.expand "%"
    return 1 == string.find(buf_path, "jdt", 1, true)
end

lualine.setup {
    options = {
        icons_enabled = false,
        component_separators = "",
        section_separators = "",
        theme = lualine_theme,
    },
    sections = {
        lualine_a = {
            "lsp_status",
        },
        lualine_b = {
            "branch",
        },
        lualine_c = {
            {
                "filename",
                path = 3,
                cond = function()
                    return not is_jdtls_buffer()
                end,
            },
            {
                "filename",
                cond = function()
                    return is_jdtls_buffer()
                end,
            },
        },
        lualine_x = { "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
    },
}
