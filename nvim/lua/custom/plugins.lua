local plugins = {
  -- Show where you jump to in a file
  {
    'edluffy/specs.nvim',
    lazy=false,
    config = function()
        require("specs").setup({
            show_jumps  = true,
            min_jump = 30,
            popup = {
                delay_ms = 0, -- delay before popup displays
                inc_ms = 10, -- time increments used for fade/resize effects 
                blend = 30, -- starting blend, between 0-100 (fully transparent), see :h winblend
                width = 50,
                winhl = "PMenu",
                fader = require('specs').sinus_fader,
                resizer = require('specs').slide_resizer
            },
            ignore_filetypes = {},
            ignore_buftypes = {
                nofile = true,
            }
        })
    end
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
    lazy=false
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
    lazy=false
  },
  -- Leap, quick motions
  -- {
  --   "ggandor/leap.nvim",
  --   config = function (_, opts)
  --     require('leap').add_default_mappings()
  --     local primary_label_colors = {
  --       fg = '#a040ff'
  --     }
  --
  --     vim.api.nvim_set_hl(0, 'LeapLabelPrimary', primary_label_colors)
  --     -- automatically set colors upon switching colorschemes
  --     vim.api.nvim_create_autocmd('ColorScheme', {
  --       callback = function ()
  --         vim.api.nvim_set_hl(0, 'LeapLabelPrimary', primary_label_colors)
  --       end
  --     })
  --   end,
  --   -- leap already lazy-loads itself
  --   lazy = false
  -- },
  -- Flash, quick motions w/ treesitter integration
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = require("custom.configs.flash").keys,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end
  },
  {
    "mfussenegger/nvim-dap",
    config = function(_, opts)
      require("core.utils").load_mappings("dap")
    end
  },
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
    },
    config = function(_, opts)
      local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(path)
      require("core.utils").load_mappings("dap_python")
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    ft = {"python"},
    opts = function()
      return require "custom.configs.null-ls"
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ui = {
        border = "rounded"
      },
      ensure_installed = {
        "black",
        "debugpy",
        "flake8",
        "isort",
        "mypy",
        "ruff",
        "pyright"
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },
}
return plugins
