local tabline = require "mini.tabline"

tabline.setup {
    format = function(buf_id, label)
        local suffix = vim.bo[buf_id].modified and " ●" or ""
        return tabline.default_format(buf_id, label .. suffix)
    end,
}

vim.keymap.set("n", "<M-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer tab" })
vim.keymap.set("n", "<M-l>", "<cmd>bnext<cr>", { desc = "Next buffer tab" })
