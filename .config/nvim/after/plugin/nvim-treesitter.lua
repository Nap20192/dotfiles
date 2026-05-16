local ts = require "nvim-treesitter"
local ts_select = require "nvim-treesitter-textobjects.select"
local ts_moves = require "nvim-treesitter-textobjects.move"
local ts_swaps = require "nvim-treesitter-textobjects.swap"
local ts_context = require "treesitter-context"
local ts_textobjects = require "nvim-treesitter-textobjects"

ts.install {
    -- languages
    "bash",
    "c",
    "clojure",
    "fennel",
    "go",
    "gomod",
    "gosum",
    "groovy",
    "javascript",
    "kotlin",
    "lua",
    "luadoc",
    "make",
    "proto",
    "python",
    "ruby",
    "rust",
    "scheme",
    "sql",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
    -- markup
    "css",
    "html",
    "markdown",
    "markdown_inline",
    "xml",
    "asm",
    "typst",
    -- config
    "dot",
    "toml",
    "yaml",
    -- data
    "csv",
    "json",
    "json5",
    -- utility
    "diff",
    "disassembly",
    "dockerfile",
    "git_config",
    "git_rebase",
    "gitcommit",
    "gitignore",
    "http",
    "mermaid",
    "printf",
    "query",
    "ssh_config",
}

vim.treesitter.language.register("javascript", "tsx")
vim.treesitter.language.register("typescript.tsc", "tsx")

-- nvim-treesitter-textobjects
vim.g.no_plugin_maps = true
ts_textobjects.setup {
    select = {
        lookahead = true,
        include_surrounding_whitespace = false,
    },
    move = {
        set_jumps = true,
    },
}

local function setup_selects()
    local buf_opts = { buffer = true }

    vim.keymap.set({ "o", "x" }, "=r", function()
        ts_select.select_textobject("@assignment.rhs", "textobjects")
    end, buf_opts)

    vim.keymap.set({ "o", "x" }, "aa", function()
        ts_select.select_textobject("@parameter.outer", "textobjects")
    end, buf_opts)
    vim.keymap.set({ "o", "x" }, "ia", function()
        ts_select.select_textobject("@parameter.inner", "textobjects")
    end, buf_opts)

    vim.keymap.set({ "o", "x" }, "ai", function()
        ts_select.select_textobject("@conditional.outer", "textobjects")
    end, buf_opts)
    vim.keymap.set({ "o", "x" }, "ii", function()
        ts_select.select_textobject("@conditional.inner", "textobjects")
    end, buf_opts)

    vim.keymap.set({ "o", "x" }, "af", function()
        ts_select.select_textobject("@function.outer", "textobjects")
    end, buf_opts)
    vim.keymap.set({ "o", "x" }, "if", function()
        ts_select.select_textobject("@function.inner", "textobjects")
    end, buf_opts)

    vim.keymap.set({ "o", "x" }, "at", function()
        ts_select.select_textobject("@class.outer", "textobjects")
    end, buf_opts)
    vim.keymap.set({ "o", "x" }, "it", function()
        ts_select.select_textobject("@class.inner", "textobjects")
    end, buf_opts)
end

local function setup_moves()
    local buf_opts = { buffer = true }

    vim.keymap.set({ "n", "o", "x" }, "]f", function()
        ts_moves.goto_next_start("@function.outer", "textobjects")
    end, buf_opts)
    vim.keymap.set({ "n", "o", "x" }, "]F", function()
        ts_moves.goto_next_end("@function.outer", "textobjects")
    end, buf_opts)

    vim.keymap.set({ "n", "o", "x" }, "[f", function()
        ts_moves.goto_previous_start("@function.outer", "textobjects")
    end, buf_opts)
    vim.keymap.set({ "n", "o", "x" }, "[F", function()
        ts_moves.goto_previous_end("@function.outer", "textobjects")
    end, buf_opts)
end

local function setup_swaps()
    local buf_opts = { buffer = true }

    vim.keymap.set("n", "<leader>man", function()
        ts_swaps.swap_next "@parameter.inner"
    end, buf_opts)
    vim.keymap.set("n", "<leader>map", function()
        ts_swaps.swap_previous "@parameter.inner"
    end, buf_opts)

    vim.keymap.set("n", "<leader>mfn", function()
        ts_swaps.swap_next "@function.inner"
    end, buf_opts)
    vim.keymap.set("n", "<leader>mfp", function()
        ts_swaps.swap_previous "@function.inner"
    end, buf_opts)
end

local ts_group = vim.api.nvim_create_augroup("vnkjd-treesitter", {})
local ts_comment_conceal_ns = vim.api.nvim_create_namespace "vnkjd-treesitter-comment-conceal"
local ts_comment_conceal_group =
    vim.api.nvim_create_augroup("vnkjd-treesitter-comment-conceal", {})

local function set_comment_conceallevel(bufnr, enabled)
    for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
        if enabled then
            if vim.w[win].vnkjd_comment_conceallevel == nil then
                vim.w[win].vnkjd_comment_conceallevel =
                    vim.api.nvim_get_option_value("conceallevel", { win = win })
            end

            vim.api.nvim_set_option_value("conceallevel", 2, { win = win })
        else
            local conceallevel = vim.w[win].vnkjd_comment_conceallevel

            if conceallevel ~= nil then
                vim.api.nvim_set_option_value("conceallevel", conceallevel, { win = win })
                vim.w[win].vnkjd_comment_conceallevel = nil
            end
        end
    end
end

local function conceal_comment_nodes(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    vim.api.nvim_buf_clear_namespace(bufnr, ts_comment_conceal_ns, 0, -1)

    local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
    if not ok or parser == nil then
        return false
    end

    local function conceal_node(node)
        if node:type() == "comment" then
            local start_row, start_col, end_row, end_col = node:range()

            if start_row ~= end_row or start_col ~= end_col then
                vim.api.nvim_buf_set_extmark(bufnr, ts_comment_conceal_ns, start_row, start_col, {
                    end_row = end_row,
                    end_col = end_col,
                    conceal = "",
                })
            end

            return
        end

        for child in node:iter_children() do
            conceal_node(child)
        end
    end

    parser:for_each_tree(function(tree)
        conceal_node(tree:root())
    end)

    return true
end

local function hide_comments(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    if not conceal_comment_nodes(bufnr) then
        vim.notify("treesitter comments: parser is not available", vim.log.levels.WARN)
        return
    end

    vim.b[bufnr].vnkjd_comments_hidden = true
    set_comment_conceallevel(bufnr, true)
    vim.notify "treesitter comments: hidden"
end

local function show_comments(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    vim.b[bufnr].vnkjd_comments_hidden = false
    vim.api.nvim_buf_clear_namespace(bufnr, ts_comment_conceal_ns, 0, -1)
    set_comment_conceallevel(bufnr, false)
    vim.notify "treesitter comments: shown"
end

local function toggle_comments(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    if vim.b[bufnr].vnkjd_comments_hidden then
        show_comments(bufnr)
    else
        hide_comments(bufnr)
    end
end

local function setup_comment_hider()
    vim.api.nvim_buf_create_user_command(0, "TreesitterCommentsHide", function()
        hide_comments()
    end, { desc = "Hide comments with treesitter" })

    vim.api.nvim_buf_create_user_command(0, "TreesitterCommentsShow", function()
        show_comments()
    end, { desc = "Show comments hidden with treesitter" })

    vim.api.nvim_buf_create_user_command(0, "TreesitterCommentsToggle", function()
        toggle_comments()
    end, { desc = "Toggle comments hidden with treesitter" })

    vim.keymap.set("n", "<localleader>hc", function()
        toggle_comments()
    end, { buffer = true, desc = "Toggle comments hidden with treesitter" })
end

vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
    callback = function(args)
        if vim.b[args.buf].vnkjd_comments_hidden then
            set_comment_conceallevel(args.buf, true)
        end
    end,
    group = ts_comment_conceal_group,
})

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    callback = function(args)
        if vim.b[args.buf].vnkjd_comments_hidden then
            conceal_comment_nodes(args.buf)
        end
    end,
    group = ts_comment_conceal_group,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = {
        "go",
        "gomod",
        "gosum",
        "lua",
        "make",
        "markdown",
        "proto",
        "python",
        "query",
        "ruby",
        "sql",
        "javascript",
        "typescript",
        "typescriptreact",
        "typst",
        "vim",
        "yaml",
    },
    callback = function()
        vim.treesitter.start()

        setup_selects()
        setup_moves()
        setup_swaps()
        setup_comment_hider()

        vim.opt_local.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

        vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.opt_local.foldmethod = "expr"

        vim.opt_local.foldcolumn = "1"
        vim.opt_local.foldlevel = 99
        vim.opt_local.foldlevelstart = 99
        vim.opt_local.foldenable = true
    end,
    group = ts_group,
})

ts_context.setup {
    enable = true,
    max_lines = 1,
    line_numbers = true,
}

vim.keymap.set("n", "[c", function()
    ts_context.go_to_context(vim.v.count1)
end, { silent = true })
