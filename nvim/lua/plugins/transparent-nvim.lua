return {
  "xiyaowong/transparent.nvim",
  lazy = false,
  config = function()
    local transparent = require "transparent"
    transparent.setup {
      extra_groups = {
        "NormalFloat",
        "NvimTreeNormal",
      },
    }
    transparent.clear_prefix "BufferLine"
    transparent.clear_prefix "NeoTree"
    transparent.clear_prefix "lualine"
    require("notify").setup {
      background_colour = "#000000",
    }
  end,
  dependencies = {
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            ["<Leader>uT"] = { "<Cmd>TransparentToggle<CR>", desc = "Toggle transparency" },
          },
        },
      },
    },
  },
}
