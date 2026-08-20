local test = require "vnkjd.functions.test"
local lint = require "vnkjd.functions.lint"
local toggle_test = require "vnkjd.functions.toggle_test"
local gotests = require "vnkjd.functions.gotests"

test.setup {
    prefix = "Go",
    var_name = "go_last_test_cmd",
    compiler = "go",
    lang = "Go",
    all = { cmd = "go test ./..." },
    package = { cmd = "go test ." },
    current = {
        node_type = "function_declaration",
        test_name_pattern = "^Test",
        cmd_fn = function(name)
            return "go test -run '^" .. name .. "$' ."
        end,
    },
}

lint.setup {
    prefix = "Go",
    var_name = "go_last_lint_cmd",
    lang = "Go",
    all = { cmd = "golangci-lint run ./..." },
}

toggle_test.setup {
    command = "GoToggleTest",
    rules = {
        {
            detect = "_test%.go$",
            gsub_pattern = "_test%.go$",
            gsub_replacement = ".go",
        },
        {
            detect = "%.go$",
            gsub_pattern = "%.go$",
            gsub_replacement = "_test.go",
        },
    },
}

vim.keymap.set("n", "<localleader>ct", gotests.generate, {
    desc = "generate go test for function under cursor",
    buffer = true,
})
vim.keymap.set("n", "<localleader>cT", gotests.generate_all, {
    desc = "generate go tests for all exported functions",
    buffer = true,
})

-- gopls refactor code actions, ported from
-- https://github.com/IlyasYOY/nvim-workbench
local function code_action(mode, key, desc, kind, apply)
    vim.keymap.set(mode, key, function()
        vim.lsp.buf.code_action {
            apply = apply,
            filter = function(a)
                return a.kind == kind
            end,
        }
    end, { desc = desc, buffer = true })
end

code_action("n", "<localleader>jl", "join lines", "refactor.rewrite.joinLines", true)
code_action("n", "<localleader>sl", "split lines", "refactor.rewrite.splitLines", true)
code_action("n", "<localleader>oi", "organize imports", "source.organizeImports", true)
code_action({ "v", "s" }, "<localleader>em", "extract to method", "refactor.extract.method", true)
code_action({ "v", "s" }, "<localleader>ef", "extract to function", "refactor.extract.function", true)
code_action({ "v", "s" }, "<localleader>ec", "extract to constant", "refactor.extract.constant", true)
code_action({ "v", "s" }, "<localleader>ev", "extract to variable", "refactor.extract.variable", true)
code_action("n", "<localleader>fs", "fill struct", "refactor.rewrite.fillStruct", false)
code_action("n", "<localleader>at", "add test (gopls)", "source.addTest", true)
