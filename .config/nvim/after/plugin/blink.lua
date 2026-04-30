require("blink.cmp").setup({
    enabled = function()
        local ok, suggestion = pcall(require, "copilot.suggestion")
        return not (ok and suggestion.is_visible())
    end,

    keymap = {
        preset = "default",
        -- <C-space> to show/force completions, <C-e> to hide, arrows/C-n/C-p to navigate
        -- <CR> accepts the selected item
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
    },

    snippets = {
        preset = "luasnip",
    },

    sources = {
        default = { "lsp", "path", "snippets", "buffer" },
    },

    fuzzy = {
        implementation = "prefer_rust_with_warning",
        sorts = { "score", "sort_text" },
    },

    completion = {
        menu = {
            draw = {
                columns = {
                    { "label", "label_description", gap = 1 },
                    { "kind_icon", "kind" },
                },
            },
        },
        documentation = {
            auto_show = true,
            auto_show_delay_ms = 200,
        },
        ghost_text = { enabled = false },
    },

    signature = { enabled = true },
})
