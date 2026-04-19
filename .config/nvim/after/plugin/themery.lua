require("themery").setup {
    themes = vim.tbl_filter(function(t)
        if type(t) ~= "string" or t == "" then return false end
        return #vim.api.nvim_get_runtime_file("colors/" .. t .. ".lua", false) > 0
            or #vim.api.nvim_get_runtime_file("colors/" .. t .. ".vim", false) > 0
    end, vim.fn.getcompletion("", "color")),
    livePreview = true,
}

vim.keymap.set("n", "<leader>th", "<cmd>Themery<cr>", { desc = "Theme picker" })
