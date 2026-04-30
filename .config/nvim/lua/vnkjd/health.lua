local M = {}

function M.check()
    vim.health.start "vnkjd"
    require("vnkjd.functions.gotests").health()
end

return M
