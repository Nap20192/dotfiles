local wezterm = require "wezterm"

local M = {}
local palettes = {
    dark = {
        fg = "#f4efe6",
        bg = "#080706",
        cursor = "#ff9900",
        cursor_text = "#18130d",
        selection_fg = "#18130d",
        selection_bg = "#ff9900",
        muted = "#8a7b67",
        ansi = {
            "#080706",
            "#d96c5f",
            "#77945f",
            "#ff9900",
            "#7193bd",
            "#a483bd",
            "#609e98",
            "#fffaf0",
        },
        brights = {
            "#8a7b67",
            "#f28a78",
            "#9bbd7a",
            "#ffb340",
            "#94b6df",
            "#c3a3dc",
            "#82beb7",
            "#f4efe6",
        },
    },
    light = {
        fg = "#18130d",
        bg = "#fffaf0",
        cursor = "#ff9900",
        cursor_text = "#18130d",
        selection_fg = "#18130d",
        selection_bg = "#ff9900",
        muted = "#746653",
        ansi = {
            "#18130d",
            "#a64c43",
            "#536f42",
            "#a35b00",
            "#4f719c",
            "#765d8d",
            "#3d7772",
            "#746653",
        },
        brights = {
            "#a89a84",
            "#bf6256",
            "#6d8956",
            "#bd7200",
            "#6788ae",
            "#8e71a4",
            "#568f89",
            "#fffaf0",
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

local opacity = 1.0
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
