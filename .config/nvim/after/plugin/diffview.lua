require("diffview").setup({
	enhanced_diff_hl = true,
})

-- <leader>gd is vim-go's GoDef (buffer-local, wins in Go files), so diffview
-- lives on gv/gV instead of colliding silently there.
vim.keymap.set("n", "<leader>gv", "<cmd>DiffviewOpen<cr>", { desc = "Diff against HEAD" })
vim.keymap.set("n", "<leader>gV", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" })
vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "File history (current buffer)" })
vim.keymap.set("n", "<leader>gH", "<cmd>DiffviewFileHistory<cr>", { desc = "File history (whole repo)" })
