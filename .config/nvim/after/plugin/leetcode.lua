-- leetcode.nvim (curl + nui-backed UI) is loaded via vim.pack with `load =
-- false` (see pack.lua): rarely used, no reason to pay its setup cost on
-- every startup. packadd + setup + :Leet happen on first actual invocation.
local loaded = false

vim.keymap.set("n", "<leader>lc", function()
    if not loaded then
        loaded = true
        vim.cmd.packadd("leetcode.nvim")
        local ok, leetcode = pcall(require, "leetcode")
        if not ok then
            return
        end
        leetcode.setup({
            lang = "rust",
        })
    end
    vim.cmd("Leet")
end, { desc = "LeetCode" })
