-- Smoke test for this nvim config. Run: tests/run.sh (or nvim --headless "+luafile tests/smoke.lua")
local failed = 0

local function check(ok, label, detail)
    if ok then
        print("OK   " .. label)
    else
        failed = failed + 1
        print("FAIL " .. label .. (detail and (": " .. detail) or ""))
    end
end

-- 1. Own lua modules load
for _, mod in ipairs {
    "vnkjd",
    "vnkjd.pack",
    "vnkjd.snippets",
    "vnkjd.hidden",
    "vnkjd.health",
    "vnkjd.functions.core",
    "vnkjd.functions.gotests",
    "vnkjd.functions.links",
    "vnkjd.functions.lint",
    "vnkjd.functions.pass",
    "vnkjd.functions.test",
    "vnkjd.functions.toggle_test",
    "vnkjd.functions.treesitter",
} do
    local ok, err = pcall(require, mod)
    check(ok, "require " .. mod, tostring(err))
end

-- 2. Key plugins load
for _, mod in ipairs {
    "fzf-lua",
    "harpoon",
    "conform",
    "blink.cmp",
    "luasnip",
    "lualine",
    "mini.files",
    "nvim-treesitter",
    "dap",
    "mason",
    "plenary",
} do
    local ok, err = pcall(require, mod)
    check(ok, "plugin " .. mod, tostring(err))
end

-- 3. after/plugin actually ran: their user commands exist
for _, cmd in ipairs { "Mason", "ConformInfo", "FzfLua", "Themery", "DiffviewOpen" } do
    check(vim.fn.exists(":" .. cmd) == 2, "command :" .. cmd)
end
check(vim.fn.maparg("<leader>gG", "n") ~= "", "keymap <leader>gG (lazygit)")

-- 4. External tools the config depends on
for _, bin in ipairs { "gotests", "rg", "git" } do
    check(vim.fn.executable(bin) == 1, "executable " .. bin)
end

-- 5. Own healthcheck reports no errors
local health_ok, health_err = pcall(function()
    require("vnkjd.functions.gotests").health()
end)
check(health_ok, "vnkjd healthcheck runs", tostring(health_err))

-- 6. Colorscheme loads
check(pcall(vim.cmd.colorscheme, "vnkjd-monochrome"), "colorscheme vnkjd-monochrome")

print(failed == 0 and "ALL PASS" or (failed .. " FAILED"))
if failed > 0 then
    vim.cmd.cquit()
else
    vim.cmd "qa!"
end
