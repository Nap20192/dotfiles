-- octo.nvim — GitHub PR review in nvim (needs authed `gh`).
-- :Octo pr list -> :Octo review start -> <leader>ca comment on line ->
-- :Octo review submit
vim.schedule(function()
    require("octo").setup({
        picker = "fzf-lua",
        enable_builtin = true,
    })
end)
