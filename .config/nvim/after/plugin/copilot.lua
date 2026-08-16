if vim.g.copilot_disable then
    return
end

-- copilot.lua spawns a Node agent process on setup(). Loaded via vim.pack
-- with `load = false` (see pack.lua), so nothing pays that cost until a
-- buffer of a filetype Copilot actually covers is opened, or a :Copilot
-- command is used directly.
local filetypes = {
    go = true,
    python = true,
    lua = true,
    rust = true,
    javascript = true,
    typescript = true,
    typescriptreact = true,
    sh = true,
    make = true,
    sql = true,
    proto = true,
    yaml = true, -- Полезно для docker-compose и k8s
    markdown = true,
    gitcommit = true,
    ["*"] = false,
}

local loaded = false

local function ensure_copilot()
    if loaded then
        return
    end
    loaded = true

    vim.cmd.packadd("copilot.lua")
    vim.cmd.packadd("copilot-lsp")

    require("copilot").setup {
        panel = { enabled = true },
        suggestion = {
            enabled = true,
            auto_trigger = true,
            keymap = {
                accept = "<M-l>",
                accept_word = "<M-w>",
                next = "<M-]>",
                prev = "<M-[>",
                dismiss = "<M-h>",
            },
        },
        -- Explicit allow-list.  `["."] = true` used to be here, which means
        -- "enable for every filetype not listed" — that fired auto_trigger in
        -- logs, fugitive buffers and huge generated files too.
        filetypes = filetypes,
    }
end

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("vnkjd-copilot-lazy", { clear = true }),
    pattern = vim.tbl_filter(function(ft)
        return filetypes[ft]
    end, vim.tbl_keys(filetypes)),
    once = true,
    callback = ensure_copilot,
})

local function map(lhs, copilot_cmd, desc)
    vim.keymap.set("n", lhs, function()
        ensure_copilot()
        vim.cmd("Copilot " .. copilot_cmd)
    end, { desc = desc })
end

map("<leader>aa", "toggle", "Toggle Copilot")
map("<leader>ae", "enable", "Enable Copilot")
map("<leader>ad", "disable", "Disable Copilot")
map("<leader>as", "status", "Status Copilot")
map("<leader>ar", "restart", "Reload Copilot")
map("<leader>ap", "panel", "Toggle Copilot Panel")
