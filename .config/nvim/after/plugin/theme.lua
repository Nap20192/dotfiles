vim.tbl_flatten = function(t) 
    return vim.iter(t):flatten(math.huge):totable() 
end

vim.cmd [[ colorscheme vnkjd-monochrome ]]

vim.schedule(function()
    require("colorizer").setup()

    require("auto-dark-mode").setup {
        dark_mode_colorscheme = "vnkjd-monochrome",
        light_mode_colorscheme = "vnkjd-monochrome",
    }
end)
