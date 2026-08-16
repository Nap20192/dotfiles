-- Building the theme list costs ~14ms at startup: 70 colorschemes x 2
-- nvim_get_runtime_file calls over a 70-entry runtimepath.  The picker is
-- opened rarely, so the scan is deferred until the first <leader>th.
local configured = false

local function collect_themes()
    return vim.tbl_filter(function(t)
        if type(t) ~= "string" or t == "" then return false end
        return #vim.api.nvim_get_runtime_file("colors/" .. t .. ".lua", false) > 0
            or #vim.api.nvim_get_runtime_file("colors/" .. t .. ".vim", false) > 0
    end, vim.fn.getcompletion("", "color"))
end

local function open_themery()
    if not configured then
        require("themery").setup {
            themes = collect_themes(),
            livePreview = true,
        }
        configured = true
    end
    vim.cmd "Themery"
end

vim.keymap.set("n", "<leader>th", open_themery, { desc = "Theme picker" })
