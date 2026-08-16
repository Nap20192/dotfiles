vim.schedule(function()
    local command = require("neo-tree.command")

    require("neo-tree").setup({
        close_if_last_window = true,
        enable_git_status = true,
        enable_diagnostics = true,
        open_files_do_not_replace_types = { "terminal", "qf" },
        default_component_configs = {
            indent = {
                indent_size = 2,
                with_markers = true,
                indent_marker = "│",
                last_indent_marker = "└",
            },
            icon = {
                folder_closed = "",
                folder_open = "",
                folder_empty = "",
                default = "",
            },
        },
        window = {
            position = "right",
            width = 34,
            mappings = {
                ["<CR>"] = "open",
                ["l"] = "open",
                ["h"] = "close_node",
                ["o"] = "open",
                ["s"] = "open_vsplit",
                ["S"] = "open_split",
                ["t"] = "open_tabnew",
                ["P"] = { "toggle_preview", config = { use_float = true } },
                ["a"] = { "add", config = { show_path = "relative" } },
                ["A"] = "add_directory",
                ["d"] = "delete",
                ["r"] = "rename",
                ["y"] = "copy_to_clipboard",
                ["x"] = "cut_to_clipboard",
                ["p"] = "paste_from_clipboard",
                ["R"] = "refresh",
                ["H"] = "toggle_hidden",
                ["z"] = "close_all_nodes",
                ["q"] = "close_window",
                ["?"] = "show_help",
            },
        },
        filesystem = {
            filtered_items = {
                visible = true,
                hide_dotfiles = false,
                hide_gitignored = false,
            },
            follow_current_file = {
                enabled = true,
                leave_dirs_open = true,
            },
            use_libuv_file_watcher = true,
        },
    })

    local function open_tree(opts)
        command.execute(vim.tbl_extend("force", {
            action = "focus",
            source = "filesystem",
            position = "right",
            reveal = true,
        }, opts or {}))
    end

    vim.keymap.set("n", "<C-b>", function()
        open_tree({ toggle = true })
    end, { desc = "Toggle neo-tree" })

    vim.keymap.set("n", "<leader>nt", function()
        open_tree({ toggle = true })
    end, { desc = "Toggle neo-tree" })

    vim.keymap.set("n", "<leader>nr", function()
        open_tree()
    end, { desc = "Reveal current file in neo-tree" })

    vim.keymap.set("n", "<leader>nb", function()
        command.execute({
            toggle = true,
            source = "buffers",
            position = "right",
        })
    end, { desc = "Toggle neo-tree buffers" })

    vim.keymap.set("n", "<leader>ng", function()
        command.execute({
            toggle = true,
            source = "git_status",
            position = "right",
        })
    end, { desc = "Toggle neo-tree git status" })
end)
