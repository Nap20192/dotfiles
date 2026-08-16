-- Deferred: nothing needs blink.cmp/luasnip ready before the first paint,
-- only before the first keystroke in insert mode (which is always later).
vim.schedule(function()
	require("luasnip.loaders.from_vscode").lazy_load()

	require("blink.cmp").setup({
		keymap = {
			preset = "default",
			["<CR>"] = { "accept", "fallback" },
		},
		signature = { enabled = true },
		fuzzy = {
			implementation = "prefer_rust",
			prebuilt_binaries = {
				force_version = "v*",
			},
		},
		completion = {
			documentation = { auto_show = true, auto_show_delay_ms = 500 },
			menu = {
				auto_show = true,
				draw = {
					treesitter = { "lsp" },
					columns = { { "kind_icon", "label", "label_description", gap = 1 }, { "kind" } },
				},
			},
		},
	})
end)
