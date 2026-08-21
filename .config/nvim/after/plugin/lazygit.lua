if vim.fn.executable("lazygit") == 0 then
	return
end

local win, buf

local function close()
	if win and vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_win_close(win, true)
	end
	win, buf = nil, nil
end

local function open()
	if win and vim.api.nvim_win_is_valid(win) then
		close()
		return
	end

	buf = vim.api.nvim_create_buf(false, true)
	local width = math.floor(vim.o.columns * 0.9)
	local height = math.floor(vim.o.lines * 0.9)
	win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		border = "rounded",
		title = " lazygit ",
	})

	vim.fn.jobstart("lazygit", {
		term = true,
		on_exit = close,
	})
	vim.cmd.startinsert()
end

vim.keymap.set("n", "<leader>gG", open, { desc = "Toggle lazygit" })
