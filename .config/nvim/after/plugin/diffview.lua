local actions = require("diffview.actions")

-- buffers diffview opened during the current view; wiped on view close
-- unless modified (ponytail: also drops files you had open before diffview
-- if you browsed onto them — reopen is one <leader>ff away)
local diffview_bufs = {}

require("diffview").setup({
	enhanced_diff_hl = true,
	hooks = {
		-- diff buffers don't need LSP diagnostics; attaching them lags every
		-- j/k auto-open step in the file panel
		diff_buf_read = function(bufnr)
			vim.diagnostic.enable(false, { bufnr = bufnr })
			diffview_bufs[bufnr] = true
		end,
		-- drop buffers diffview opened while browsing, unless they were edited;
		-- keeps mini.tabline/:ls from filling up with every file j/k touched
		view_closed = function()
			for bufnr in pairs(diffview_bufs) do
				if
					vim.api.nvim_buf_is_loaded(bufnr)
					and not vim.bo[bufnr].modified
					and vim.fn.bufwinid(bufnr) == -1
				then
					pcall(vim.api.nvim_buf_delete, bufnr, {})
				end
			end
			diffview_bufs = {}
		end,
	},
	keymaps = {
		-- j/k in the file panel opens the moved-to file's diff immediately,
		-- no extra Enter needed
		file_panel = {
			{ "n", "j", actions.select_next_entry, { desc = "Next file (auto-open diff)" } },
			{ "n", "k", actions.select_prev_entry, { desc = "Prev file (auto-open diff)" } },
		},
		file_history_panel = {
			{ "n", "j", actions.select_next_entry, { desc = "Next entry (auto-open diff)" } },
			{ "n", "k", actions.select_prev_entry, { desc = "Prev entry (auto-open diff)" } },
		},
	},
})

-- <leader>gd is vim-go's GoDef (buffer-local, wins in Go files), so diffview
-- lives on gv/gV instead of colliding silently there.
-- -uno: skip untracked files — they have no diff to show and bloat the panel
-- (untracked are still visible in <leader>gs); <leader>gu shows everything
vim.keymap.set("n", "<leader>gv", "<cmd>DiffviewOpen -uno<cr>", { desc = "Diff against HEAD (tracked only)" })
vim.keymap.set("n", "<leader>gu", "<cmd>DiffviewOpen<cr>", { desc = "Diff against HEAD (incl. untracked)" })
-- fast path: fuzzy-pick a changed file (diff shown in preview), Enter opens
-- diffview for that file only instead of the whole repo
vim.keymap.set("n", "<leader>gs", function()
	require("fzf-lua").git_status({
		actions = {
			["enter"] = function(selected, opts)
				local file = require("fzf-lua.path").entry_to_file(selected[1], opts).path
				vim.cmd("DiffviewOpen -- " .. vim.fn.fnameescape(file))
			end,
		},
	})
end, { desc = "Git status picker (Enter = diff file)" })
vim.keymap.set("n", "<leader>gV", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" })
vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "File history (current buffer)" })
vim.keymap.set("n", "<leader>gH", "<cmd>DiffviewFileHistory<cr>", { desc = "File history (whole repo)" })
