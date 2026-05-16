local ok, leetcode = pcall(require, "leetcode")
if not ok then
    return
end

leetcode.setup {
    lang = "golang",
}

vim.keymap.set("n", "<leader>lc", "<cmd>Leet<cr>", { desc = "LeetCode" })
