local wezterm = require "wezterm"

local M = {}

M.font_size = 13


M.font = wezterm.font "Fira Code"

M.color_schemes = {

    ["Monochrome Dark"] = {
        foreground = "#dadada",
        background = "#000000",
        cursor_bg = "#8787af",
        cursor_fg = "#000000",
        cursor_border = "#8787af",
        selection_fg = "#000000",
        selection_bg = "#ffaf00",
        scrollbar_thumb = "#707070",
        split = "#707070",
        ansi = {
            "#191919", -- black   (noise)
            "#722529", -- red     (remove)
            "#416241", -- green   (add)
            "#ffaf00", -- yellow  (visual)
            "#00afff", -- blue    (search)
            "#8787af", -- magenta (cursor)
            "#00afaf", -- cyan
            "#dadada", -- white   (fg)
        },
        brights = {
            "#303030", -- bright black  (subtle)
            "#ff005f", -- bright red    (error)
            "#8dda9e", -- bright green  (light add)
            "#ffaf00", -- bright yellow (visual)
            "#00afff", -- bright blue   (search)
            "#d787d7", -- bright magenta
            "#87afd7", -- bright cyan
            "#ffffff", -- bright white
        },
    },

    ["Monochrome Light"] = {
        foreground = "#000000",
        background = "#ffffff",
        cursor_bg = "#8787af",
        cursor_fg = "#dadada",
        cursor_border = "#8787af",
        selection_fg = "#dadada",
        selection_bg = "#ffaf00",
        scrollbar_thumb = "#626262",
        split = "#626262",
        ansi = {
            "#000000", -- black   (fg)
            "#da8d8d", -- red     (remove)
            "#8dda9e", -- green   (add)
            "#ffaf00", -- yellow  (visual)
            "#000000", -- blue    (black)
            "#8787af", -- magenta (cursor)
            "#00afaf", -- cyan
            "#727272", -- white   (bg)
        },
        brights = {
            "#626262", -- bright black  (muted)
            "#ff005f", -- bright red    (error)
            "#416241", -- bright green  (dark add)
            "#ffaf00", -- bright yellow (visual)
            "#000000", -- bright blue   (black)
            "#d787d7", -- bright magenta
            "#87afd7", -- bright cyan
            "#828282", -- bright white
        },
    },
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
