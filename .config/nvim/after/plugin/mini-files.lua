vim.schedule(function()
    local minifiles = require "mini.files"

    minifiles.setup {
        content = {
            filter = nil,
        },
        mappings = {
            close = "q",
            go_in = "l",
            go_in_plus = "<CR>",
            go_out = "h",
            go_out_plus = "H",
            mark_goto = "'",
            mark_set = "m",
            reset = "<BS>",
            reveal_cwd = "@",
            show_help = "g?",
            synchronize = "=",
            trim_left = "<",
            trim_right = ">",
        },
        options = {
            use_as_default_explorer = false,
        },
        windows = {
            preview = true,
            width_focus = 40,
            width_nofocus = 20,
            width_preview = 50,
        },
    }

    local function open_minifiles(path)
        minifiles.open(path, true)
    end

    vim.keymap.set("n", "<leader>m", function()
        local path = vim.api.nvim_buf_get_name(0)
        open_minifiles(path ~= "" and path or vim.uv.cwd())
    end, { desc = "Open mini.files" })

    vim.keymap.set("n", "<leader>M", function()
        open_minifiles(vim.uv.cwd())
    end, { desc = "Open mini.files at cwd" })
end)
