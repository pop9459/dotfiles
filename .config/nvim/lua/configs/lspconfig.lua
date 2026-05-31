local nvchad_lsp = require "nvchad.configs.lspconfig"
nvchad_lsp.defaults()

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

-- read :h vim.lsp.config for changing options of lsp servers
