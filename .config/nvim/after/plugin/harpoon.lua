local harpoon = require "harpoon"

harpoon:setup({
    settings = {
        save_on_toggle = true,
        sync_on_ui_close = true,
    },
})

vim.keymap.set("n", "<leader>ha", function()
    harpoon:list():add()
end, { desc = "Harpoon add file" })

vim.keymap.set("n", "<leader>hh", function()
    harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Harpoon quick menu" })
