return {
  "tpope/vim-dadbod",
  specs = {
    {
      "kristijanhusak/vim-dadbod-ui",
      dependencies = { "tpope/vim-dadbod" },
      event = "VeryLazy",
    },
    {
      "hrsh7th/nvim-cmp",
      optional = true,
      dependencies = {
        {
          "kristijanhusak/vim-dadbod-completion",
          config = function()
            vim.api.nvim_create_autocmd("FileType", {
              pattern = { "sql", "mysql", "plsql" },
              callback = function()
                require("cmp").setup.buffer({ sources = { { name = "vim-dadbod-completion" } } })
              end,
            })
          end,
        },
      },
    },
  },
}
