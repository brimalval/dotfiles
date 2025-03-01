return {
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        keymaps = {
          visual = "S",
        },
      })
    end,
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    -- -@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = require("config.flash").keys,
  },
  {
    "supermaven-inc/supermaven-nvim",
    config = function()
      require("supermaven-nvim").setup({
        keymaps = {
          accept_suggestion = "<C-l>",
          clear_suggestion = "<C-]>",
          accept_word = "<C-;>",
        },
      })
    end,
  },
  {
    "max397574/better-escape.nvim",
    config = function()
      require("better_escape").setup()
    end,
  },
  {
    "diepm/vim-rest-console",
    ft = { "http", "rest" },
    config = function()
      vim.g.vrc_response_default_content_type = "application/json"
      vim.g.vrc_output_buffer_name = "__VRC_OUTPUT.json"
      vim.g.vrc_auto_format_response_patterns = {
        json = "jq",
      }
      vim.g.vrc_show_command = true
    end,
  },
  -- Coerce into camelCase, snake_case,
  {
    "tpope/vim-abolish",
    event = "VeryLazy",
  },
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      -- add a keymap to browse plugin files
      -- stylua: ignore
      {
        "<leader>/",
        function() require("telescope.builtin").current_buffer_fuzzy_find() end,
        desc = "Find in current buffer",
      },
    },
    -- change some options
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 0,
      },
    },
  },
  -- Superseded by flash + treesitter
  -- {
  --   "sustech-data/wildfire.nvim",
  --   event = "VeryLazy",
  --   dependencies = { "nvim-treesitter/nvim-treesitter" },
  --   config = function()
  --     require("wildfire").setup()
  --   end,
  -- },
  -- Lua
  {
    "folke/twilight.nvim",
    opts = {},
  },
  -- Lua
  {
    "folke/zen-mode.nvim",
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },
  {
    "tpope/vim-fugitive",
    event = "VeryLazy",
  },
  {
    "sustech-data/wildfire.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("wildfire").setup()
    end,
  },
}
