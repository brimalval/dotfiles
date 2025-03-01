return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    config = function()
      require("rose-pine").setup({
        variant = "main",
      })
    end,
  },
  -- LazyVim exclusive
  { "LazyVim/LazyVim", opts = { colorscheme = "rose-pine-main" } },
}
