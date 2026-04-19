local gh = function(x)
    return "https://github.com/" .. x
end

-- Dev plugins: use local path if it exists, else fall back to GitHub.
local function vnkjd(name)
    local local_path = vim.fn.expand("~/Projects/vnkjd/" .. name)
    if vim.fn.isdirectory(local_path) == 1 then
        return { src = "file://" .. local_path, name = name }
    else
        return gh("vnkjd/" .. name)
    end
end

local M = {
    specs = {
        core = {

            -- Dev (own) plugins
            vnkjd "theme.nvim",
            gh "windwp/nvim-autopairs",

            -- Colors
            gh "catgoose/nvim-colorizer.lua",
            gh "f-person/auto-dark-mode.nvim",

            -- Navigation & file management
            gh "christoomey/vim-tmux-navigator",

            -- UI
            gh "nvim-lualine/lualine.nvim",
            gh "folke/which-key.nvim",
            gh"dmtrKovalenko/fff.nvim",

            -- Snippets
            gh "L3MON4D3/LuaSnip",

            -- LSP
            gh "neovim/nvim-lspconfig",

            -- Mason (LSP/tool installer)
            gh "williamboman/mason.nvim",
            gh "WhoIsSethDaniel/mason-tool-installer.nvim",

            -- Treesitter
            gh "nvim-treesitter/nvim-treesitter",
            {
                src = gh "nvim-treesitter/nvim-treesitter-textobjects",
                version = "main",
            },
            gh "nvim-treesitter/nvim-treesitter-context",

            -- Utilities
            gh "nvim-lua/plenary.nvim",

            -- Text manipulation
            gh "tpope/vim-abolish",
        },
        fzf_lua = {
            gh "ibhagwan/fzf-lua",
        },
        oil = {
            gh "stevearc/oil.nvim",
        },
        dap = {
            gh "mfussenegger/nvim-dap",
            gh "theHamsta/nvim-dap-virtual-text",
            gh "rcarriga/nvim-dap-ui",
            gh "nvim-neotest/nvim-nio",
        },
        dap_go = {
            gh "leoluz/nvim-dap-go",
        },
        dap_python = {
            gh "mfussenegger/nvim-dap-python",
        },
        jdtls = {
            gh "mfussenegger/nvim-jdtls",
        },
        dadbod = {
            gh "tpope/vim-dadbod",
            gh "kristijanhusak/vim-dadbod-completion",
            gh "kristijanhusak/vim-dadbod-ui",
        },
        git_tools = {
            gh "tpope/vim-dispatch",
            gh "shumphrey/fugitive-gitlab.vim",
            gh "tommcdo/vim-fubitive",
            gh "tpope/vim-rhubarb",
            gh "tpope/vim-fugitive",
        },
        copilot = {
            gh "zbirenbaum/copilot.lua",
            -- This plugin is required for NES support.
            -- I don't use NES, but I include it anyway.
            gh "copilotlsp-nvim/copilot-lsp",
        },
        obs = {
            vnkjd "obs.nvim",
        },
    },
}

for _, group in ipairs {
    "core",
    "fzf_lua",
    "oil",
    "dap",
    "dap_go",
    "dap_python",
    "jdtls",
    "dadbod",
    "git_tools",
    "copilot",
    "obs",
} do
    vim.pack.add(M.specs[group])
end

return M
