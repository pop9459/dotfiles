return {
    {
        "stevearc/conform.nvim",
        -- event = 'BufWritePre', -- uncomment for format on save
        opts = require "configs.conform",
    },

    {
        "neovim/nvim-lspconfig",
        config = function()
            require "configs.lspconfig"
        end,
    },

    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        event = "VeryLazy",
        opts = require "configs.mason-tool-installer",
        dependencies = { "williamboman/mason.nvim" },
    },

    {
        "JoosepAlviste/nvim-ts-context-commentstring",
        event = "BufReadPre",
        config = function()
            require("ts_context_commentstring").setup {
                enable_autocmd = false,
            }
        end,
    },

    {
        "numToStr/Comment.nvim",
        opts = function()
            return {
                pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
            }
        end,
    },

    {
        "github/copilot.vim",
        lazy = false,
        config = function()
            vim.g.copilot_no_tab_map = true
            vim.g.copilot_assume_mapped = true
        end,
    },
}
