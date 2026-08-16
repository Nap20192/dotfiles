-- Deferred: pairs.build():pwait(60000) can block synchronously for up to a
-- minute on a missing prebuilt binary. Doing that off the startup path means
-- a fresh install never hangs Neovim's launch.
vim.schedule(function()
    local pairs = require("blink.pairs")

    if not pairs.library_available() then
        pairs.build():pwait(60000)
    end

    pairs.setup({
        mappings = {
            enabled = true,
            cmdline = true,
            disabled_filetypes = {},
            wrap = {
                ["<C-b>"] = "motion",
                ["<C-S-b>"] = "motion_reverse",
            },
            pairs = {},
        },
        highlights = {
            enabled = true,
            cmdline = true,
            groups = {
                "BlinkPairsOrange",
                "BlinkPairsPurple",
                "BlinkPairsBlue",
            },
            unmatched_group = "BlinkPairsUnmatched",
            matchparen = {
                enabled = true,
                cmdline = false,
                include_surrounding = false,
                group = "BlinkPairsMatchParen",
                priority = 250,
            },
        },
        debug = false,
    })
end)
