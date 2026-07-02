require("mason-lspconfig").setup()

vim.keymap.set("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Go to next diagnostic message" })

vim.keymap.set("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Go to previous diagnostic message" })

vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

---GOLANG---
vim.lsp.config("gopls", {
	settings = {
		gopls = {
			analyses = {
				unusedparams = true, -- Warn about unused function parameters
				shadow = true, -- Warn about variable shadowing
			},
			hints = {
				compositeLiteralFields = true, -- <--- THIS is what you want for struct fields!
				parameterNames = true, -- Shows function parameter names
				assignVariableTypes = true, -- Shows types on variable assignments
				compositeLiteralTypes = true,
				constantValues = true,
				functionTypeParameters = true,
				rangeVariableTypes = true,
			},
			staticcheck = true, -- Enables advanced static analysis checks
			gofumpt = true, -- Uses a stricter, more opinionated formatter (if installed)
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
	on_attach = function(_, bufnr)
		if vim.lsp.inlay_hint then
			vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
		end
	end,
	settings = {
		["rust-analyzer"] = {
			imports = {
				granularity = {
					group = "module",
				},
				prefix = "self",
			},
			cargo = {
				allFeatures = true,
				buildScripts = {
					enable = true, -- Necessary for macros and build.rs to resolve correctly
				},
				targetDir = true,
			},
			procMacro = {
				enable = true, -- Enables support for procedural macros (like serde or tokio)
			},
			check = {
				command = "clippy", -- Runs Clippy linter instead of just 'cargo check'
				allTargets = true,
			},
			diagnostics = {
				enable = true,
			},
		},
	},
})
vim.lsp.enable("rust_analyzer")

---PYTHON---
vim.lsp.config("basedpyright", {
	on_attach = function(_, bufnr)
		if vim.lsp.inlay_hint then
			vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
		end
	end,
	settings = {
		basedpyright = {
			analysis = {
				typeCheckingMode = "standard", -- "off" | "basic" | "standard" | "strict"
				autoImportCompletions = true,
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
				diagnosticMode = "openFilesOnly", -- "openFilesOnly" | "workspace"
				inlayHints = {
					variableTypes = true,
					callArgumentNames = true,
					functionReturnTypes = true,
					genericTypes = true,
				},
			},
		},
	},
})
vim.lsp.enable("basedpyright")

-- ruff handles linting + formatting; let basedpyright own hover/type info
vim.lsp.config("ruff", {
	on_attach = function(client, _)
		client.server_capabilities.hoverProvider = false
	end,
})
vim.lsp.enable("ruff")

--GENERAL---
local opts = { noremap = true, silent = true }
vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
vim.keymap.set("n", "<leader>fo", "<cmd>Format<CR>", opts)
