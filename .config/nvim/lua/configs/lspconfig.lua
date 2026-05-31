local nvchad_lsp = require "nvchad.configs.lspconfig"
nvchad_lsp.defaults()

-- Configure intelephense with 4-space indentation
vim.lsp.config("intelephense", {
    settings = {
        intelephense = {
            files = {
                maxSize = 5000000,
            },
            completion = {
                insertUseDeclaration = true,
            },
        },
    },
})

-- Add extra servers here. lua_ls already enabled by NVChad defaults.
local servers = {
    "pyright",
    "tsserver",
    "html",
    "cssls",
    "jsonls",
    "bashls",
    "clangd",
    "jdtls",
    "intelephense",
}
vim.lsp.enable(servers)

-- Set Neovim's indent for PHP files
vim.api.nvim_create_autocmd("FileType", {
    pattern = "php",
    callback = function()
        vim.opt_local.shiftwidth = 4
        vim.opt_local.tabstop = 4
        vim.opt_local.softtabstop = 4
    end,
})

-- read :h vim.lsp.config for changing options of lsp servers
