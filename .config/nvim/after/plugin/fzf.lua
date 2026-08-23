vim.schedule(function()
    require("fzf-lua").setup({
        fzf_colors = true,
        previewers = {
            builtin = {
                treesitter = { enabled = true },
            },
        },
        winopts = {
            border = "rounded",
            preview = {
                default = "builtin",
                border = "rounded",
                layout = "vertical",
                vertical = "up:60%",
                title_pos = "center",
            },
        },
        keymap = {
            fzf = {
                ["alt-j"] = "down",
                ["alt-k"] = "up",
            },
        },
    })

    -- прямое переключение без пикера
    vim.keymap.set("n", "<A-j>", "<cmd>bnext<cr>", { desc = "next buffer" })
    vim.keymap.set("n", "<A-k>", "<cmd>bprevious<cr>", { desc = "prev buffer" })
    -- <A-h>/<A-l> (== <M-h>/<M-l>) belong to mini-tabline's buffer switching;
    -- tabs are gt/gT.

    -- пикеры с превью на отдельных биндингах
    -- zoxide: прыжок cwd в частые каталоги (как cd в шелле и Z в yazi)
    vim.keymap.set("n", "<leader>fz", function()
        require("fzf-lua").fzf_exec("zoxide query -l", {
            prompt = "Zoxide> ",
            preview = "eza -la --color=always {}",
            actions = {
                ["enter"] = function(selected)
                    if not selected[1] then return end
                    vim.cmd.cd(selected[1])
                    vim.system({ "zoxide", "add", selected[1] })
                    vim.notify("cwd: " .. selected[1])
                end,
            },
        })
    end, { desc = "zoxide cd picker" })

    vim.keymap.set("n", "<leader>fb", function() require("fzf-lua").buffers() end, { desc = "buffers picker" })
    vim.keymap.set("n", "<leader>ft", function() require("fzf-lua").tabs() end, { desc = "tabs picker" })
end)
