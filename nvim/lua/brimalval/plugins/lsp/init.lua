return {
  "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",
  {
    "neovim/nvim-lspconfig",
    opts = {
      ---@type lspconfig.options
      servers = {
        -- pyright will be automatically installed with mason and loaded with lspconfig
        pyright = {},
        vtsls = {},
        tailwindcss = {},
        eslint = {},
        sqls = {},
        prismals = {},
        lua_ls = {},
      },
      diagnostics = {
        virtual_text = false,
        float = { border = "rounded" },
      },
    },
  },
}
