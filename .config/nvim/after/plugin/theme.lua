vim.cmd [[ colorscheme vnkjd-monochrome ]]

vim.schedule(function()
    require("colorizer").setup()
end)

require("auto-dark-mode").setup {
    dark_mode_colorscheme = "vnkjd-monochrome",
    light_mode_colorscheme = "vnkjd-monochrome",
}
