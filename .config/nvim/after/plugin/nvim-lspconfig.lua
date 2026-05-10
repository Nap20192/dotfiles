local function described(x, desc)
    return vim.tbl_extend("force", x, { desc = desc })
end

local function toggle_codelens(bufnr)
    local filter = { bufnr = bufnr }
    vim.lsp.codelens.enable(not vim.lsp.codelens.is_enabled(filter), filter)
end

local function go_organize_imports(bufnr)
    local clients = vim.lsp.get_clients { bufnr = bufnr, name = "gopls" }
    local client = clients[1]
    if not client then
        return
    end

    local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
    params.context = {
        only = { "source.organizeImports" },
        diagnostics = {},
    }

    local response = client:request_sync(
        "textDocument/codeAction",
        params,
        3000,
        bufnr
    )

    for _, action in ipairs(response and response.result or {}) do
        if action.edit then
            vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
        end

        if action.command then
            vim.lsp.buf.execute_command(action.command)
        end
    end
end

local function go_format(bufnr)
    go_organize_imports(bufnr)
    vim.lsp.buf.format {
        async = false,
        bufnr = bufnr,
        timeout_ms = 10000,
        filter = function(client)
            return client.name == "gopls"
        end,
    }
end

local function lsp_attach(data)
    local bufopts = { noremap = true, silent = true, buffer = data.buf }

    vim.keymap.set("n", "<C-s>", vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set("n", "grs", function()

        vim.lsp.buf.typehierarchy "subtypes"

    end, described(bufopts, "go to subtypes"))

    vim.keymap.set("n", "grS", function()

        vim.lsp.buf.typehierarchy "supertypes"
    end, described(bufopts, "go to supertypes"))
    vim.keymap.set(
        "n",
        "grd",
        vim.lsp.buf.definition,
        described(bufopts, "go to definitions")
    )
    vim.keymap.set(
        "n",
        "grD",
        vim.lsp.buf.declaration,
        described(bufopts, "go to declaration")
    )
    vim.keymap.set(
        "n",
        "grT",
        vim.lsp.buf.typehierarchy,
        described(bufopts, "go to typehierarchy")
    )

    vim.keymap.set({ "n", "v" }, "<localleader>oc", function()
        vim.lsp.buf.format { async = false, timeout_ms = 10000 }
    end, described(bufopts, "organize code"))

    vim.keymap.set(
        "n",
        "<localleader>d",
        vim.diagnostic.open_float,
        described(bufopts, "diagnostics")
    )

    local client = vim.lsp.get_client_by_id(data.data.client_id)
    if not client then
        return
    end

    vim.lsp.codelens.enable(false, { bufnr = data.buf })
    vim.keymap.set("n", "<localleader>lcl", function()
        toggle_codelens(data.buf)
    end, described(bufopts, "toggle code lens"))
    vim.keymap.set(
        "n",
        "grA",
        vim.lsp.codelens.run,
        described(bufopts, "run code lens")
    )

    if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
        vim.keymap.set("n", "<localleader>lih", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
        end, described(bufopts, "Toggle Inlay Hints"))
    end

    client.server_capabilities.semanticTokensProvider = nil

    if client.name == "jdtls" then
        require("jdtls").setup_dap()
    end

    if client.name == "tinymist" then
        vim.api.nvim_buf_create_user_command(0, "TypstPreview", function()
            vim.lsp.buf.execute_command {
                command = "tinymist.startDefaultPreview",
                arguments = {},
            }
        end, {
            desc = "Start typst preview using tinymist",
        })
    end
end

vim.lsp.config("gopls", {
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    settings = {
        gopls = {
            gofumpt = true,
            completeUnimported = true,
            usePlaceholders = false,
            staticcheck = true,
            analyses = {
                unusedparams = true,
            },
        },
    },
})
vim.lsp.config("rust-analyzer", {
    settings = {
        ["rust-analyzer"] = {
            check = {
                command = "clippy",
            },
            procMacro = {
                enable = true,
            },
            cargo = {
                allFeatures = true,
            },
            completion = {
                postfix = {
                    enable = true,
                },
            },
        },
    },
})
vim.lsp.config("tinymist", {
    settings = {
        preview = {
            background = {
                enabled = true,
            },
        },
        formatterMode = "typstyle",
    },
})

for _, server in ipairs {
    "bashls",
    "ts_ls",
    "lua_ls",
    "basedpyright",
    "gopls",
    "tinymist",
    "kotlin_lsp",
    "rust-analyzer",
} do
    vim.lsp.enable(server)
end

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("vnkjd.lsp", {}),
    callback = lsp_attach,
})

vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("vnkjd.go", {}),
    pattern = { "*.go" },
    callback = function(args)
        go_format(args.buf)
    end,
})
