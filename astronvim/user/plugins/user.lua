return {
  -- You can also add new plugins here as well:
  -- Add plugins, the lazy syntax
  -- "andweeb/presence.nvim",
  -- {
  --   "ray-x/lsp_signature.nvim",
  --   event = "BufRead",
  --   config = function()
  --     require("lsp_signature").setup()
  --   end,
  -- },
  {
    'edluffy/specs.nvim',
    lazy = false,
    config = function()
      require("specs").setup({
        show_jumps       = true,
        min_jump         = 30,
        popup            = {
          delay_ms = 0,       -- delay before popup displays
          inc_ms = 10,        -- time increments used for fade/resize effects
          blend = 30,         -- starting blend, between 0-100 (fully transparent), see :h winblend
          width = 50,
          winhl = "PMenu",
          fader = require('specs').sinus_fader,
          resizer = require('specs').slide_resizer
        },
        ignore_filetypes = {},
        ignore_buftypes  = {
          nofile = true,
        }
      })
    end
  },
  {
    "tpope/vim-fugitive",
    lazy = false
  },
  -- Find and replace
  {
    "nvim-pack/nvim-spectre",
    lazy = false,
  },
  -- Quick annotation
  {
    "danymat/neogen",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = true,
    -- Uncomment next line if you want to follow only stable versions
    -- version = "*"
    ft = { "python" }
  },
  -- Quick motions for changing/deleting around a text
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
      })
    end
  },
  -- Sticky context based on LSP
  {
    "nvim-treesitter/nvim-treesitter-context",
    ft = { "python" }
  },
  -- Quick project file navigation
  {
    "ThePrimeagen/harpoon",
    dependencies = {
      "nvim-lua/plenary.nvim"
    },
    lazy = false
  },
  -- Winbar/breadcrumbs
  {
    "utilyre/barbecue.nvim",
    name = "barbecue",
    version = "*",
    dependencies = {
      "SmiteshP/nvim-navic",
      "nvim-tree/nvim-web-devicons", -- optional dependency
    },
    opts = {
      -- configurations go here
    },
    lazy = false
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    -- -@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = require("user.configs.flash").keys,
  }
}
