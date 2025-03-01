return {
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
}
