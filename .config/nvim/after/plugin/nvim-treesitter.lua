local treesitter_languages = {
	"go",
	"gomod",
	"gosum",
	"lua",
	"make",
	"markdown",
	"proto",
	"python",
	"query",
	"ruby",
	"sql",
	"javascript",
	"typescript",
	"tsx",
	"typst",
	"vim",
	"yaml",
}

require("nvim-treesitter").setup({
	install_dir = vim.fn.stdpath("data") .. "/site",
})

-- nvim-treesitter (main branch) needs the tree-sitter CLI to build parsers.
-- Without it install() is skipped, no parser ever lands in install_dir, and
-- every vim.treesitter.start() below fails silently inside its pcall — the
-- buffer quietly falls back to the regex syntax engine.  So say it out loud.
if vim.fn.executable("tree-sitter") == 1 then
	require("nvim-treesitter").install(treesitter_languages)
else
	vim.schedule(function()
		vim.notify(
			"tree-sitter CLI not found: parsers cannot be installed, "
				.. "highlighting falls back to regex syntax. "
				.. "Install it (`:MasonInstall tree-sitter-cli`) and restart.",
			vim.log.levels.WARN
		)
	end)
end

-- Visually hide comments with treesitter, toggled per buffer with <localleader>hc.
local comment_conceal_ns = vim.api.nvim_create_namespace("vnkjd-treesitter-comment-conceal")
local comment_conceal_group = vim.api.nvim_create_augroup("vnkjd-treesitter-comment-conceal", { clear = true })

local function set_comment_conceallevel(bufnr, enabled)
	for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
		if enabled then
			if vim.w[win].vnkjd_comment_conceallevel == nil then
				vim.w[win].vnkjd_comment_conceallevel =
					vim.api.nvim_get_option_value("conceallevel", { win = win })
			end
			vim.api.nvim_set_option_value("conceallevel", 2, { win = win })
		else
			local conceallevel = vim.w[win].vnkjd_comment_conceallevel
			if conceallevel ~= nil then
				vim.api.nvim_set_option_value("conceallevel", conceallevel, { win = win })
				vim.w[win].vnkjd_comment_conceallevel = nil
			end
		end
	end
end

local function conceal_comment_nodes(bufnr)
	vim.api.nvim_buf_clear_namespace(bufnr, comment_conceal_ns, 0, -1)

	local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
	if not ok or parser == nil then
		return false
	end

	local function conceal_node(node)
		if node:type() == "comment" then
			local start_row, start_col, end_row, end_col = node:range()
			if start_row ~= end_row or start_col ~= end_col then
				vim.api.nvim_buf_set_extmark(bufnr, comment_conceal_ns, start_row, start_col, {
					end_row = end_row,
					end_col = end_col,
					conceal = "",
				})
			end
			return
		end
		for child in node:iter_children() do
			conceal_node(child)
		end
	end

	parser:for_each_tree(function(tree)
		conceal_node(tree:root())
	end)

	return true
end

local function hide_comments(bufnr)
	if not conceal_comment_nodes(bufnr) then
		vim.notify("treesitter comments: parser is not available", vim.log.levels.WARN)
		return
	end
	vim.b[bufnr].vnkjd_comments_hidden = true
	set_comment_conceallevel(bufnr, true)
end

local function show_comments(bufnr)
	vim.b[bufnr].vnkjd_comments_hidden = false
	vim.api.nvim_buf_clear_namespace(bufnr, comment_conceal_ns, 0, -1)
	set_comment_conceallevel(bufnr, false)
end

local function toggle_comments(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	if vim.b[bufnr].vnkjd_comments_hidden then
		show_comments(bufnr)
	else
		hide_comments(bufnr)
	end
end

vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
	group = comment_conceal_group,
	callback = function(args)
		if vim.b[args.buf].vnkjd_comments_hidden then
			set_comment_conceallevel(args.buf, true)
		end
	end,
})

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
	group = comment_conceal_group,
	callback = function(args)
		if vim.b[args.buf].vnkjd_comments_hidden then
			conceal_comment_nodes(args.buf)
		end
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("vnkjd-treesitter-start", { clear = true }),
	pattern = treesitter_languages,
	callback = function(args)
		local ok = pcall(vim.treesitter.start, args.buf)
		if ok then
			vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end

		vim.keymap.set("n", "<localleader>hc", function()
			toggle_comments(args.buf)
		end, { buffer = args.buf, desc = "Toggle comments hidden with treesitter" })
	end,
})
