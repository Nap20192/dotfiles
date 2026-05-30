vim.tbl_flatten = function(t) 
    return vim.iter(t):flatten(math.huge):totable() 
end

vim.cmd [[ colorscheme vnkjd-orange ]]

vim.schedule(function()
    require("colorizer").setup()
end)

require("auto-dark-mode").setup {
    dark_mode_colorscheme = "vnkjd-orange",
    light_mode_colorscheme = "vnkjd-orange",
}
