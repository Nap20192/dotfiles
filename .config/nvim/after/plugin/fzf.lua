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
vim.keymap.set("n", "<A-l>", "<cmd>tabnext<cr>", { desc = "next tab" })
vim.keymap.set("n", "<A-h>", "<cmd>tabprevious<cr>", { desc = "prev tab" })

-- пикеры с превью на отдельных биндингах
vim.keymap.set("n", "<leader>fb", function() require("fzf-lua").buffers() end, { desc = "buffers picker" })
vim.keymap.set("n", "<leader>ft", function() require("fzf-lua").tabs() end, { desc = "tabs picker" })
