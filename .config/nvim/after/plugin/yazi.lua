-- yazi.nvim — full yazi in a floating window; replaces the neo-tree sidebar.
-- Same entry points as the old tree: <C-b> reveals the current file.
vim.schedule(function()
    require("yazi").setup({
        open_for_directories = true, -- nvim <dir> opens yazi instead of netrw
        floating_window_scaling_factor = 0.9,
    })

    vim.keymap.set("n", "<C-b>", "<cmd>Yazi<cr>", { desc = "Yazi at current file" })
    vim.keymap.set("n", "<leader>nt", "<cmd>Yazi cwd<cr>", { desc = "Yazi in cwd" })
    vim.keymap.set("n", "<leader>nr", "<cmd>Yazi toggle<cr>", { desc = "Resume last yazi session" })
end)
