-- Make sure to setup `mapleader` and `maplocalleader` before
-- registering plugins so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.g.go_highlight_functions = 1
vim.g.go_highlight_function_calls = 1

require("vnkjd.pack")

vim.o.autoread = true

vim.cmd("packadd nvim.difftool")
vim.cmd("packadd nvim.undotree")

vim.cmd("source ~/.vimrc")

vim.opt.completeopt = { "popup", "menu", "menuone", "noselect" }

vim.o.spelllang = "ru_ru,en_us"
vim.o.spellfile = vim.fn.expand("~/.config/nvim/spell/custom.utf-8.add")
vim.o.winborder = "rounded"

vim.diagnostic.config({ virtual_text = true })

-- Dev things

vim.keymap.set("n", "<leader>d", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostic" })

vim.keymap.set("n", "<localleader>sc", function()
	vim.opt_local.spell = not (vim.opt_local.spell:get())
	vim.notify("spell: " .. tostring(vim.opt_local.spell))
end, { desc = "Toggle spell check" })

vim.keymap.set("n", "<leader>cp", function()
	local path = vim.fn.expand("%:.")
	path = "./" .. path
	vim.fn.setreg("+", path)
	vim.notify("copied: " .. path)
end, { desc = "Copy relative file path to clipboard" })

vim.keymap.set("n", "<leader>cP", function()
	local abs_path = vim.fn.expand("%:p")
	vim.fn.setreg("+", abs_path)
	vim.notify("copied absolute path: " .. abs_path)
end, { desc = "Copy absolute file path to clipboard" })

vim.keymap.set("v", "<leader>cp", function()
	vim.api.nvim_feedkeys(
		vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
		"nx", -- 'n' for normal mode, 'x' to update '<' and '>' marks correctly
		false
	)
	local start_line = vim.fn.line("'<")
	local end_line = vim.fn.line("'>")
	local path = vim.fn.expand("%:.")
	if start_line ~= end_line then
		path = path .. ":" .. start_line .. "-" .. end_line
	else
		path = path .. ":" .. start_line
	end
	path = "./" .. path
	vim.fn.setreg("+", path)
	vim.notify("copied: " .. path)
end, { desc = "Copy relative file path with line numbers to clipboard" })

vim.keymap.set("v", "<leader>cP", function()
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
	local path = vim.fn.expand("%:p")
	local start_line = vim.fn.line("'<")
	local end_line = vim.fn.line("'>")
	if start_line ~= end_line then
		path = path .. ":" .. start_line .. "-" .. end_line
	else
		path = path .. ":" .. start_line
	end
	vim.fn.setreg("+", path)
	vim.notify("copied: " .. path)
end, { desc = "Copy absolute file path with line numbers to clipboard" })

vim.keymap.set("n", "<leader>?", function()
	vim.cmd("edit " .. vim.fn.stdpath("config") .. "/HINTS.md")
end, { desc = "Open keybinding hints (HINTS.md)" })

vim.keymap.set("n", "<C-S-w>", function()
	local current = vim.api.nvim_get_current_buf()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if buf ~= current and vim.bo[buf].buflisted then
			vim.cmd.bdelete(buf)
		end
	end
end, { desc = "Close other buffers" })

vim.api.nvim_create_user_command("RenderMarkdown", function()
	local file = vim.fn.expand("%:p")
	vim.cmd("botright vertical split | terminal glow " .. vim.fn.shellescape(file))
end, { desc = "Preview markdown with glow" })

vim.keymap.set("n", "<localleader>fm", "<cmd>RenderMarkdown<cr>", { desc = "Preview markdown with glow" })

vim.api.nvim_create_user_command("OpenLink", function()
	require("vnkjd.functions.links").open_under_cursor()
end, { desc = "Open URL under cursor" })

vim.keymap.set("n", "gx", function()
	require("vnkjd.functions.links").open_under_cursor()
end, { desc = "Open URL under cursor" })

vim.keymap.set("x", "gx", function()
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
	require("vnkjd.functions.links").open_visual_selection()
end, { desc = "Open URL in selection" })
