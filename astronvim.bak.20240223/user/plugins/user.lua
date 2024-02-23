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
  -- {
  --   'edluffy/specs.nvim',
  --   lazy = false,
  --   config = function()
  --     require("specs").setup({
  --       show_jumps       = true,
  --       min_jump         = 30,
  --       popup            = {
  --         delay_ms = 0,       -- delay before popup displays
  --         inc_ms = 10,        -- time increments used for fade/resize effects
  --         blend = 30,         -- starting blend, between 0-100 (fully transparent), see :h winblend
  --         width = 50,
  --         winhl = "PMenu",
  --         fader = require('specs').sinus_fader,
  --         resizer = require('specs').slide_resizer
  --       },
  --       ignore_filetypes = {},
  --       ignore_buftypes  = {
  --         nofile = true,
  --       }
  --     })
  --   end
  -- },
  {
    "tpope/vim-fugitive",
    lazy = false,
  },
  -- Find and replace
  {
    "nvim-pack/nvim-spectre",
    lazy = false,
  },
  -- Quick annotation
  -- {
  --   "danymat/neogen",
  --   dependencies = "nvim-treesitter/nvim-treesitter",
  --   config = true,
  --   -- Uncomment next line if you want to follow only stable versions
  --   -- version = "*"
  --   ft = { "python" },
  -- },
  -- Quick motions for changing/deleting around a text
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function() require("nvim-surround").setup {} end,
  },
  -- Sticky context based on LSP
  -- {
  --   "nvim-treesitter/nvim-treesitter-context",
  --   ft = { "python" },
  -- },
  -- Quick project file navigation
  -- {
  --   "ThePrimeagen/harpoon",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --   },
  --   lazy = false,
  -- },
  -- Winbar/breadcrumbs
  -- {
  --   "utilyre/barbecue.nvim",
  --   name = "barbecue",
  --   version = "*",
  --   dependencies = {
  --     "SmiteshP/nvim-navic",
  --     "nvim-tree/nvim-web-devicons", -- optional dependency
  --   },
  --   opts = {
  --     -- configurations go here
  --   },
  --   event = "LspAttach",
  -- },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    -- -@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = require("user.configs.flash").keys,
  },
  -- Nice UI replacement for cmdline among other things
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- add any options here
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
    },
    config = function()
      require("noice").setup {
        lsp = {
          hover = {
            enabled = false,
          },
          signature = {
            enabled = false,
          },
          -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        -- you can enable a preset for easier configuration
        presets = {
          bottom_search = true, -- use a classic bottom cmdline for search
          command_palette = true, -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = false, -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = false, -- add a border to hover docs and signature help
        },
      }
    end,
    -- {
    --   "b0o/schemastore.nvim",
    --   config = function()
    --     require("lspconfig").jsonls.setup {
    --       settings = {
    --         json = {
    --           schemas = require("schemastore").json.schemas {
    --             extra = {
    --               {
    --                 description = "GHA",
    --                 url = "https://raw.githubusercontent.com/SchemaStore/schemastore/master/src/schemas/json/github-workflow.json",
    --                 fileMatch = { "dev.yml", "prod.yml" },
    --                 name = "workflows",
    --               },
    --             },
    --           },
    --           validate = { enable = true },
    --         },
    --       },
    --     }
    --   end,
    -- },
  },
  {
    "Exafunction/codeium.vim",
    config = function()
      -- Change '<C-g>' here to any keycode you like.
      vim.keymap.set("i", "<C-k>", function() return vim.fn["codeium#Accept"]() end, { expr = true, silent = true })
    end,
  },
}
