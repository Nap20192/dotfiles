local wezterm = require "wezterm"

local M = {}

M.font_size = 12
M.font = wezterm.font "Fira Code"

M.color_schemes = {
    ["IlyasYOY Monochrome Dark"] = {
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

    ["IlyasYOY Monochrome Light"] = {
        foreground = "#000000",
        background = "#eeeeee",
        cursor_bg = "#4e4e4e",
        cursor_fg = "#eeeeee",
        cursor_border = "#4e4e4e",
        selection_fg = "#eeeeee",
        selection_bg = "#ffaf00",
        scrollbar_thumb = "#626262",
        split = "#626262",
        ansi = {
            "#000000", -- black
            "#da8d8d", -- red
            "#111111", -- green   → gray-1
            "#ffaf00", -- yellow
            "#3b3b3b", -- blue    → gray-4
            "#4e4e4e", -- magenta → gray-5
            "#252525", -- cyan    → gray-3
            "#727272", -- white   (muted)
        },
        brights = {
            "#626262", -- bright black
            "#ff005f", -- bright red
            "#1c1c1c", -- bright green   → gray-2
            "#ffaf00", -- bright yellow
            "#454545", -- bright blue    → gray-6
            "#575757", -- bright magenta → gray-7
            "#303030", -- bright cyan    → gray-3b
            "#828282", -- bright white
        },
    },
}

local function scheme_for_appearance(appearance)
    if appearance:find "Dark" then
        return "IlyasYOY Monochrome Dark"
    else
        return "IlyasYOY Monochrome Light"
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
  left = 15,
  right = 15,
  top = 15,
  bottom = 15,
}

M.send_composed_key_when_left_alt_is_pressed = false
M.send_composed_key_when_right_alt_is_pressed = false

M.native_macos_fullscreen_mode = true

M.default_prog = { "tmux", "new-session", "-A", "-s", "main" }

return M
