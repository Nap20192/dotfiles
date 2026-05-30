local conform = require "conform"

conform.setup {
    formatters_by_ft = {
        lua = { "stylua" },
        go = { "goimports", "gofumpt" },
        python = { "isort", "ruff_format" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        html = { "prettier" },
        yaml = { "prettier" },
        markdown = { "mdsf" },
        proto = { "buf" },
        sql = { "sqlfluff" },
    },
    default_format_opts = {
        timeout_ms = 10000,
        lsp_format = "fallback",
    },
    format_on_save = {
        timeout_ms = 10000,
        lsp_format = "fallback",
    },
}

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

vim.api.nvim_create_user_command("Format", function(args)
    conform.format {
        async = false,
        bufnr = args.buf,
        lsp_format = "fallback",
    }
end, { desc = "Format current buffer" })

vim.keymap.set("n", "<leader>fo", function()
    conform.format {
        async = true,
        lsp_format = "fallback",
    }
end, { desc = "Format current buffer" })
