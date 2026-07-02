local has_clipboard_tool = vim.fn.executable "wl-copy" == 1
    or vim.fn.executable "xclip" == 1
    or vim.fn.executable "xsel" == 1
    or vim.fn.executable "pbcopy" == 1
    or vim.fn.executable "win32yank.exe" == 1

if has_clipboard_tool then
    vim.opt.clipboard = "unnamedplus"
else
    vim.opt.clipboard = ""
    vim.g.clipboard = "osc52"
end

vim.opt.list = false
vim.opt.linebreak = true
vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.showbreak = "↳ "

vim.g.netrw_liststyle = 3
vim.g.netrw_banner = 0 -- отключает огромный бесполезный баннер сверху
vim.g.netrw_browse_split = 0 -- открывает файл в том же окне
vim.g.netrw_winsize = 25 -- ширина дерева в % (если открывать как сингл-бар)

vim.keymap.set("n", "<leader>e", "<cmd>Explore<CR>", { desc = "Open file explorer" })
vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode" })
vim.keymap.set("n", ";", ":", { desc = "Command mode" })
