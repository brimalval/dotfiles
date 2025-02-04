return {
  -- Add language servers
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
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
      },
      diagnostics = {
        virtual_text = false,
        float = { border = "rounded" },
      },
      -- setup = {
      --   eslint = function()
      --     require("lazyvim.util").lsp.on_attach(function(client)
      --       if client.name == "eslint" then
      --         client.server_capabilities.documentFormattingProvider = true
      --       elseif client.name == "tsserver" then
      --         client.server_capabilities.documentFormattingProvider = false
      --       end
      --     end)
      --   end,
      -- },
    },
  },
  -- Disable "No information available" on hover
  {
    "folke/noice.nvim",
    opts = {
      -- Add border to floating windows
      presets = {
        lsp_doc_border = true,
      },
      lsp = {
        hover = {
          -- Disable message if hover is not available
          -- ex: shift+k on Typescript code
          silent = true,
        },
      },
    },
  },
  -- Formatting
  {
    "stevearc/conform.nvim",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      {
        "williamboman/mason.nvim",
        opts = {
          ensure_installed = {
            "black",
            "isort",
            "prettier",
            "eslint-lsp",
            "sqlfluff",
            "eslint_d",
          },
        },
      },
    },
    opts = {
      formatters_by_ft = {
        sql = { "sqlfluff" },
        python = { "black", "isort" },
        typescript = { "prettier", "eslint_d" },
        typescriptreact = { "prettier", "eslint_d" },
      },
    },
  },
  -- inline dynamic hints about the type of variables you query
  {
    "marilari88/twoslash-queries.nvim",
    config = function()
      require("twoslash-queries").setup({
        multi_line = true, -- to print types in multi line mode
        -- is_enabled = false, -- to keep disabled at startup and enable it on request with the TwoslashQueriesEnable
        highlight = "Type", -- to set up a highlight group for the virtual text
      })
    end,
  },
}
