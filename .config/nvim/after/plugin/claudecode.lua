vim.schedule(function()
	local ok, claudecode = pcall(require, "claudecode")
	if not ok then
		return
	end

	-- The plugin hands the provider a command string plus an env table holding
	-- ENABLE_IDE_INTEGRATION / FORCE_CODE_TERMINAL / CLAUDE_CODE_SSE_PORT.
	--
	-- A tmux pane does NOT inherit the caller's environment — new panes get the
	-- tmux *server* env — so every variable has to be passed with an explicit
	-- `-e KEY=VAL` (tmux >= 3.0).  A new ghostty window is a normal child
	-- process, so there the env table set by jobstart is enough.
	local function external_terminal_cmd(cmd_string, env_table)
		if vim.env.TMUX then
			local argv = { "tmux", "split-window", "-h", "-l", "40%" }
			for key, value in pairs(env_table or {}) do
				table.insert(argv, "-e")
				table.insert(argv, key .. "=" .. value)
			end
			table.insert(argv, cmd_string)
			return argv
		end

		return {
			"ghostty",
			"--working-directory=" .. vim.uv.cwd(),
			"-e",
			"sh",
			"-c",
			cmd_string,
		}
	end

	claudecode.setup({
		auto_start = true,
		log_level = "info",
		terminal_cmd = nil, -- `claude` is on PATH
		track_selection = true,
		focus_after_send = false,
		terminal = {
			provider = "external",
			provider_opts = {
				external_terminal_cmd = external_terminal_cmd,
			},
		},
		diff_opts = {
			layout = "vertical",
			open_in_new_tab = false,
			auto_resize_terminal = false,
		},
	})

	local function map(lhs, rhs, desc, mode)
		vim.keymap.set(mode or "n", lhs, rhs, { desc = desc })
	end

	map("<leader>kk", "<cmd>ClaudeCode<cr>", "Claude: start/stop session")
	map("<leader>kf", "<cmd>ClaudeCodeFocus<cr>", "Claude: focus session")
	map("<leader>kr", "<cmd>ClaudeCode --resume<cr>", "Claude: resume session")
	map("<leader>kc", "<cmd>ClaudeCode --continue<cr>", "Claude: continue session")
	map("<leader>km", "<cmd>ClaudeCodeSelectModel<cr>", "Claude: select model")
	map("<leader>kb", "<cmd>ClaudeCodeAdd %<cr>", "Claude: add current buffer")
	map("<leader>ks", "<cmd>ClaudeCodeSend<cr>", "Claude: send selection", "v")
	map("<leader>ky", "<cmd>ClaudeCodeDiffAccept<cr>", "Claude: accept diff")
	map("<leader>kn", "<cmd>ClaudeCodeDiffDeny<cr>", "Claude: reject diff")
	map("<leader>kS", "<cmd>ClaudeCodeStatus<cr>", "Claude: status")

	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("vnkjd-claudecode-tree", { clear = true }),
		pattern = "neo-tree",
		callback = function(args)
			vim.keymap.set("n", "<leader>ks", "<cmd>ClaudeCodeTreeAdd<cr>", {
				buffer = args.buf,
				desc = "Claude: add selected tree entries",
			})
		end,
	})
end)
