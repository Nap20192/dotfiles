-- Stays synchronous: nvim-lspconfig.lua sources right after this
-- (alphabetically) and calls mason-lspconfig.setup(), which needs
-- mason.setup() to have already run.
local mason = require("mason")

mason.setup({
	PATH = "append",
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
})

vim.defer_fn(function()
	require("mason-tool-installer").setup({
		ensure_installed = {
			"autopep8",
			"basedpyright",
			"bash-language-server",
			"buf",
			"debugpy",
			"delve",
			"eslint_d",
			"gofumpt",
			"goimports",
			"golangci-lint",
			"golines",
			"gopls",
			"gotestsum",
			"isort",
			"jsonlint",
			"kotlin-lsp",
			"lua-language-server",
			"markdownlint",
			"mdsf",
			"prettier",
			"protolint",
			"pylint",
			"ruff",
			"rust-analyzer",
			"sqlfluff",
			"stylelint",
			"stylua",
			"tinymist",
			-- required by nvim-treesitter (main) to build parsers
			"tree-sitter-cli",
			"typescript-language-server",
			"yamllint",
		},
		-- luacheck is installed outside Mason because its LuaRocks package
		-- currently fails to resolve dependencies against Lua 5.5.
		start_delay = 0,
	})
end, 0)
