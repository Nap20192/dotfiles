vim.opt.clipboard = "unnamedplus"

vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode" })
vim.keymap.set("n", ";", ":", { desc = "Command mode" })

-- Disable built-in LSP completion (blink.cmp handles it)
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("hidden.disable_builtin_completion", {}),
    callback = function(data)
        vim.schedule(function()
            vim.lsp.completion.enable(false, data.data.client_id, data.buf)
        end)
    end,
})

vim.schedule(function()
    local ok, wk = pcall(require, "which-key")
    if not ok then return end
    wk.setup {}
end)

vim.schedule(function()
    local ok, blink = pcall(require, "blink.cmp")
    if not ok then return end
    blink.setup {
        keymap = {
            preset = "none",
            ["<M-Space>"] = { "show", "fallback" },
            ["<M-e>"]     = { "hide", "fallback" },
            ["<M-y>"]     = { "select_and_accept", "fallback" },
            ["<M-n>"]     = { "select_next", "fallback" },
            ["<M-p>"]     = { "select_prev", "fallback" },
            ["<C-j>"]     = { "snippet_forward", "fallback" },
            ["<C-k>"]     = { "snippet_backward", "fallback" },
        },
        completion = {
            trigger = {
                show_on_insert_on_trigger_character = true,
            },
            menu = {
                direction_priority = { "s", "n" },
            },
            documentation = {
                auto_show = true,
                auto_show_delay_ms = 0,
            },
            list = {
                selection = {
                    preselect = false,
                },
            },
        },
        -- Fixed the deprecated fields below:
        fuzzy = {
            frecency = { enabled = true },
            proximity = { enabled = true },
            typo_resistance = { enabled = true },
        },
    }
end)
