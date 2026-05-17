require("mason-lspconfig").setup()
---GOLANG---
vim.lsp.config("gopls", {
	settings = {
		gopls = {
			analyses = {
				unusedparams = true, -- Warn about unused function parameters
				shadow = true,       -- Warn about variable shadowing
			},
			staticcheck = true,      -- Enables advanced static analysis checks
			gofumpt = true,          -- Uses a stricter, more opinionated formatter (if installed)
		},
	},
})
vim.lsp.enable("gopls")

---LUA---
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				globals = {
					"vim",
					"require",
				},
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
			},
			telemetry = {
				enable = false,
			},
		},
	},
})
vim.lsp.enable("lua_ls")

---RUST---
vim.lsp.config("rust_analyzer", {
	settings = {
		["rust-analyzer"] = {
			imports = {
				granularity = {
					group = "module",
				},
				prefix = "self",
			},
			cargo = {
				buildScripts = {
					enable = true, -- Necessary for macros and build.rs to resolve correctly
				},
			},
			procMacro = {
				enable = true, -- Enables support for procedural macros (like serde or tokio)
			},
			checkOnSave = {
				command = "clippy", -- Runs Clippy linter on save instead of just 'cargo check'
			},
		},
	},
})
vim.lsp.enable("rust_analyzer")

--GENERAL---
local opts = { noremap = true, silent = true }
vim.keymap.set('n','gd',"<cmd>lua vim.lsp.buf.definition()<CR>",opts)
vim.keymap.set('n',"<leader>fo", "<cmd>lua vim.lsp.buf.formatting()<CR>",opts)
