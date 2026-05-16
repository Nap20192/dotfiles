local wezterm = require "wezterm"

local M = {}
local palettes = {
    dark = {
        fg = "#dadada",
        bg = "#000000",
        cursor = "#ffaf00",
        cursor_text = "#000000",
        selection_fg = "#000000",
        selection_bg = "#ffaf00",
        muted = "#707070",
        ansi = {
            "#000000",
            "#b35a4f",
            "#6d8758",
            "#ffaf00",
            "#6c8db5",
            "#9a7bb8",
            "#5d9690",
            "#dadada",
        },
        brights = {
            "#4a4a4a",
            "#d77a61",
            "#93ad6d",
            "#ffaf00",
            "#8eabd1",
            "#b59ad1",
            "#7db8af",
            "#f3eadb",
        },
    },
    light = {
        fg = "#000000",
        bg = "#fff7df",
        cursor = "#ffaf00",
        cursor_text = "#000000",
        selection_fg = "#000000",
        selection_bg = "#ffaf00",
        muted = "#626262",
        ansi = {
            "#000000",
            "#ad5a4d",
            "#5f7a4f",
            "#ffaf00",
            "#5e7fa8",
            "#866ea8",
            "#4f8b85",
            "#6f6557",
        },
        brights = {
            "#9b907f",
            "#cf745d",
            "#78935f",
            "#ffaf00",
            "#7d98bd",
            "#a189c0",
            "#6ea79f",
            "#fff7df",
        },
    },
}

local function scheme(colors)
    return {
        foreground = colors.fg,
        background = colors.bg,
        cursor_bg = colors.cursor,
        cursor_fg = colors.cursor_text,
        cursor_border = colors.cursor,
        selection_fg = colors.selection_fg,
        selection_bg = colors.selection_bg,
        scrollbar_thumb = colors.muted,
        split = colors.muted,
        ansi = colors.ansi,
        brights = colors.brights,
    }
end

local opacity = 0.8
M.window_background_opacity = opacity

M.font_size = 13

M.font = wezterm.font "Fira Code"

M.color_schemes = {
    ["Monochrome Dark"] = scheme(palettes.dark),
    ["Monochrome Light"] = scheme(palettes.light),
}


local function scheme_for_appearance(appearance)
    if appearance:find "Dark" then
        return "Monochrome Dark"
    else
        return "Monochrome Light"
    end
end

wezterm.on("window-config-reloaded", function(window, _)
    local overrides = window:get_config_overrides() or {}
    local appearance = window:get_appearance()
    local scheme = scheme_for_appearance(appearance)

    if overrides.color_scheme ~= scheme then
        overrides.color_scheme = scheme
        window:set_config_overrides(overrides)
    end
end)

M.color_scheme = scheme_for_appearance(wezterm.gui.get_appearance())

M.hide_tab_bar_if_only_one_tab = true
M.window_decorations = "NONE"
M.window_padding = {
  left = 20,
  right = 20,
  top = 20,
  bottom = 5,
}

M.adjust_window_size_when_changing_font_size = false
M.send_composed_key_when_left_alt_is_pressed = false
M.send_composed_key_when_right_alt_is_pressed = false
M.enable_kitty_keyboard = true

M.keys = {
    {
        key = "c",
        mods = "CTRL|SHIFT",
        action = wezterm.action.CopyTo "ClipboardAndPrimarySelection",
    },
    {
        key = "v",
        mods = "CTRL|SHIFT",
        action = wezterm.action.PasteFrom "Clipboard",
    },
    {
        key = "Insert",
        mods = "CTRL",
        action = wezterm.action.CopyTo "ClipboardAndPrimarySelection",
    },
    {
        key = "Insert",
        mods = "SHIFT",
        action = wezterm.action.PasteFrom "Clipboard",
    },
}

return M
