vim.opt.clipboard = "unnamedplus"

vim.opt.linebreak = true
vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.showbreak = "↳ "

vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode" })
vim.keymap.set("n", ";", ":", { desc = "Command mode" })


