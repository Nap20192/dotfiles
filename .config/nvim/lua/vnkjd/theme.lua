local M = {}

M.palettes = {
    dark = {
        bg = "#000000",
        fg = "#dadada",
        elevated = "#1c1c1c",
        subtle = "#303030",
        muted = "#707070",
        noise = "#191919",
        search = "#00afff",
        visual = "#ffaf00",
        add = "#416241",
        remove = "#722529",
        change = "#2a2a2a",
        change_text = "#5f7a4f",
        error = "#ff005f",
        cursor = "#ffaf00",
        cursor_text = "#000000",
        selection_fg = "#000000",
        selection_bg = "#ffaf00",
    },
    light = {
        bg = "#fff7df",
        fg = "#000000",
        elevated = "#f3eadb",
        subtle = "#e4d9c0",
        muted = "#626262",
        noise = "#9b907f",
        search = "#00afff",
        visual = "#ffaf00",
        add = "#8dda9e",
        remove = "#da8d8d",
        change = "#e4d9c0",
        change_text = "#5f7a4f",
        error = "#ff005f",
        cursor = "#ffaf00",
        cursor_text = "#000000",
        selection_fg = "#000000",
        selection_bg = "#ffaf00",
    },
}

function M.get(mode)
    return assert(M.palettes[mode], "unknown nvim theme mode: " .. tostring(mode))
end

return M
