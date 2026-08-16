-- nvim-dap + dapui + dap-go + dap-python are loaded via vim.pack with `load
-- = false` (see pack.lua): debugging isn't used every session, so nothing
-- here should spin up dapui or spawn adapters until a debug keymap fires.
local loaded = false

local function ensure_dap()
    if loaded then
        return
    end
    loaded = true

    vim.cmd.packadd("nvim-dap")
    vim.cmd.packadd("nvim-dap-virtual-text")
    vim.cmd.packadd("nvim-nio")
    vim.cmd.packadd("nvim-dap-ui")
    vim.cmd.packadd("nvim-dap-go")
    vim.cmd.packadd("nvim-dap-python")

    local dap = require "dap"
    local dapui = require "dapui"
    dapui.setup()

    require("nvim-dap-virtual-text").setup()

    require("dap-go").setup()
    local dap_python = require "dap-python"
    dap_python.setup "uv"
    dap_python.test_runner = "pytest"

    dap.listeners.before.attach.dapui_config = function()
        dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
        dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
    end
end

local function map(mode, lhs, fn, desc)
    vim.keymap.set(mode, lhs, function()
        ensure_dap()
        fn()
    end, { desc = desc })
end

map("n", "<F2>", function()
    require("dap").terminate()
    require("dapui").close()
end, "Stop debugging")

map("n", "<F5>", function()
    require("dap").continue()
end, "Continue debugging")

map("n", "<F6>", function()
    require("dap").repl.open()
end, "Open REPL")

map("n", "<F7>", function()
    require("dap").run_to_cursor()
end, "Run debugging to cursor")

map("n", "<F10>", function()
    require("dap").step_over()
end, "Step over")

map("n", "<F11>", function()
    require("dap").step_into()
end, "Step into")

map("n", "<F12>", function()
    require("dap").step_out()
end, "Step out")

map("n", "<leader>Db", function()
    require("dap").toggle_breakpoint()
end, "Toggle Debug breakpoint")

map("n", "<leader>DB", function()
    local condition = vim.fn.input "Breakpoint condition: "
    require("dap").set_breakpoint(condition)
end, "Toggle Debug conditional Breakpoint")

map("n", "<leader>Du", function()
    require("dapui").toggle { layout = 2 }
end, "Toggle Simple Debug ui, I mainly use it to run tests")

map("n", "<leader>DU", function()
    require("dapui").toggle()
end, "Toggle Full Debug ui")
