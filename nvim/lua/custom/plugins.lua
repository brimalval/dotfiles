local plugins = {
  -- Leap, quick motions
  {
    "ggandor/leap.nvim",
    config = function (_, opts)
      require('leap').add_default_mappings()
      local primary_label_colors = {
        fg = '#a040ff'
      }
      vim.api.nvim_set_hl(0, 'LeapLabelPrimary', primary_label_colors)
      -- automatically set colors upon switching colorschemes
      vim.api.nvim_create_autocmd('ColorScheme', {
        callback = function ()
          vim.api.nvim_set_hl(0, 'LeapLabelPrimary', primary_label_colors)
        end
      })
    end,
    -- leap already lazy-loads itself
    lazy = false
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
