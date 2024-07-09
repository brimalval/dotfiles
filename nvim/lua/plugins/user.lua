-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- You can also add or configure plugins by creating files in this `plugins/` folder
-- Here are some examples:

---@type LazySpec
return {
  {
    "tpope/vim-fugitive",
    lazy = false,
  },
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function() require("nvim-surround").setup {} end,
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    -- -@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = require("configs.flash").keys,
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
  },
  {
    "Exafunction/codeium.vim",
    config = function()
      -- Change '<C-g>' here to any keycode you like.
      vim.keymap.set("i", "<C-k>", function() return vim.fn["codeium#Accept"]() end, { expr = true, silent = true })
    end,
  },

  -- == Examples of Adding Plugins ==

  -- Shows nvim as a status in Discord
  -- "andweeb/presence.nvim",
  {
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    config = function() require("lsp_signature").setup() end,
  },

  -- == Examples of Overriding Plugins ==

  -- customize alpha options
  {
    "goolord/alpha-nvim",
    opts = function(_, opts)
      -- customize the dashboard header
      opts.section.header.val = {
        [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⣿⣿⣿⣿⣿⣿⣿⣿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
        [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠀⣿⣿⣿⣿⣿⣿⣿⣿⣷⠘⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
        [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
        [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠀⠀⢿⣿⣿⣿⣿⣿⣿⣿⡿⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
        [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠘⣛⣭⣉⠉⠭⢝⡛⠃⠀⠀⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
        [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⢛⣥⠄⠀⠀⣀⣉⣵⣾⣿⣿⣶⣦⣀⠀⠀⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
        [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⣴⣿⢏⣠⡶⠟⣩⣿⣿⣿⣿⣿⣿⣯⠻⣿⣶⣄⠠⠙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
        [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⢀⣼⢟⣵⣿⢋⣴⣿⣿⣿⣿⣿⠉⢻⣿⣿⣦⠛⢿⣿⣿⣦⣄⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
        [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⢠⣾⣿⣿⡿⣣⣿⣿⣿⣿⣿⣿⡏⡀⢼⢹⣿⣿⡄⠠⡻⣿⣿⣿⣦⠙⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
        [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⢀⣿⣿⣿⡏⢠⣿⣿⣿⡟⣹⣿⠛⢡⣿⠈⢸⣿⣿⡇⢰⡅⠘⣿⣿⣿⡇⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
        [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠁⣼⣿⣿⡿⢀⣿⣿⣿⡟⢠⣿⡟⢠⣾⣿⢀⢸⣿⣿⡇⣼⣿⣆⠘⣿⣿⣧⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
        [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⢸⣿⡟⡇⢸⣿⢹⡿⢡⣾⠏⣠⣯⣙⠛⠸⣸⣿⣿⠡⠿⣛⣿⣷⡘⣧⣿⡆⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
        [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⢸⡟⠃⢁⣿⠏⡜⣰⠟⠁⠀⠀⠈⣉⠿⠆⣿⣿⡟⠰⠟⠛⡛⠛⠣⠹⢻⢳⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
        [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⢸⣿⠀⠘⠸⠃⠓⡉⠀⡆⠀⠀⠀⣿⣷⢰⣿⡿⢠⡄⠀⠀⠌⣦⠀⠀⠘⠈⢸⣿⣿⣿⢋⣭⠉⣿⠟⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
        [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⡿⢃⠀⡀⠠⠃⣶⣷⣶⣤⣶⣾⣿⡟⣼⣿⢃⢿⣷⣦⣤⣤⣥⣼⠃⢸⠀⢸⣿⣿⡇⣾⠇⡆⢃⣾⠇⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
        [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⡇⡌⠒⠾⠀⢸⣿⣿⣿⣿⣿⣿⡿⣰⣿⢃⣾⣾⣿⣿⣿⣿⣿⡿⣰⢸⢀⠸⠿⠋⠰⠏⣸⠇⣼⠏⡄⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
        [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠏⠀⡇⢎⠻⣧⣄⠀⢸⣿⣿⣿⣿⣿⡿⠁⠟⣡⣿⠿⣿⣿⣿⣿⣿⣿⠇⣿⠀⠠⣆⠂⠃⠃⣼⢿⠃⡿⠀⣣⣶⠌⢿⣿⣿⣿⣿⣿⣿⣿⣿]],
        [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠋⣼⢸⡇⣾⣷⢈⠣⠀⠸⣿⣿⣿⣿⡿⠁⣠⠚⠁⠀⠀⠂⢻⣿⣿⣿⡿⢸⡇⢠⡘⢣⣴⣦⣾⣿⣦⣈⢡⡾⠋⢐⣂⡘⣿⣿⣿⣿⣿⣿⣿⣿]],
        [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⢁⣼⠃⢺⡇⣿⡟⡈⠀⢸⣦⡙⣿⣿⣿⣷⣾⡇⠀⠀⠀⠀⠀⣼⣿⣿⡟⠀⢸⣇⠘⠛⡆⠹⣿⣿⣿⣿⠁⠋⠔⣛⣙⡟⠃⠘⠛⢿⣿⣿⣿⣿⣿]],
        [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⣰⠟⣱⠎⣾⠃⡿⠃⠀⡘⠀⣿⣿⣿⣿⣿⣿⣿⣷⡢⢿⣶⣶⣰⣿⣿⠏⣴⡁⣿⣿⡄⠀⠃⢰⣬⡙⢟⣷⣿⣿⣿⣿⣿⢃⠀⣸⣆⢠⡙⢿⣿⣿⣿]],
        [[⣿⣿⣿⣿⣿⣿⣿⣿⡟⢡⠚⢁⣾⠇⢠⡏⠀⡏⢠⠈⠁⠀⣿⣿⣿⣿⣿⣿⡿⢿⣿⣿⣿⣿⣿⠟⢡⣾⡇⠁⣸⣿⡏⣸⠀⢸⣿⣿⡆⠈⠛⠻⣿⣿⣿⠟⢀⣿⣿⠈⠑⣄⠉⠙⢿]],
        [[⣿⣿⣿⣿⣿⣿⡿⠋⢀⡀⠠⢿⠏⡄⣼⢰⠀⢠⣾⣷⣦⡄⠏⠿⣿⣿⣿⣿⣿⣦⠈⠙⠛⠛⠁⠐⣸⡿⠁⣰⣿⣿⢣⣿⠀⢸⣿⣿⣷⣄⠀⠈⠘⠛⠁⠀⣼⣿⡏⠀⠁⢿⡀⠺⣤]],
        [[⣿⣿⣿⣿⣿⠟⠐⡠⢠⣶⣶⣶⢠⣇⠁⣬⣐⡜⣿⣯⠻⣷⢸⣶⣦⣍⡛⠿⢿⣿⣷⣤⠐⣷⣦⣤⡟⠁⠀⠉⠀⢀⣤⣥⣄⣋⣩⡙⠿⣿⡷⠀⠀⠀⠀⠀⠙⠛⠁⢰⠆⠸⣷⡀⠈]],
        [[⣿⣿⣿⡿⠃⣠⠞⣠⣿⣿⣿⡇⣾⠈⣸⣿⣿⣷⡘⣿⣷⣿⢸⣿⣿⣌⠻⣷⣶⣶⣭⣥⡄⢻⣿⠋⣤⢀⣀⣀⢀⣀⡑⠻⣿⣿⣇⠘⣆⠀⠂⠰⢤⣄⡀⠀⠀⠀⠀⣼⠀⠀⠹⣿⣄]],
        [[⣿⣿⡿⠀⣼⠏⣸⣿⣿⣿⣿⢀⡟⢀⣿⣿⣿⣿⣿⡘⢿⣿⡆⣿⣿⣿⣦⡙⣿⣿⡿⠈⠁⡀⠄⠀⢻⣦⡻⣿⣿⣿⣿⡦⡈⠻⣿⣇⠹⡀⠀⠁⠀⠀⠀⠀⠀⠀⠐⠁⠀⠀⠀⠘⣿]],
        [[⣿⠟⠀⣼⡟⣰⣿⣿⣿⣿⡏⢸⡇⢸⣿⣎⠻⣿⣿⣿⣷⣮⣅⠹⡸⣿⣿⣷⣌⡻⠁⠀⠀⠀⠀⣵⡄⢷⣶⣾⣿⣿⣿⣿⣌⠢⠘⣿⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈]],
        [[⠟⡀⢸⣿⠇⣟⣿⣿⣿⣿⡇⣸⡇⣿⣿⣿⣷⡌⢿⣿⣿⣿⣿⣆⢧⢍⡻⢿⡿⢡⣤⣀⠀⠀⠀⠀⠀⠀⠻⣿⣿⣿⣿⡙⢿⣧⡀⠹⠀⠀⠀⠀⠰⣄⠀⠀⠀⠑⠂⠀⣀⣀⣄⣀⣀]],
        [[⣼⠇⠘⠛⠀⣾⣿⣿⣿⣿⡇⣿⡇⣿⣿⣿⣿⣿⣦⠻⣿⣿⣿⣿⡜⡈⣿⣦⣵⣿⣿⣿⣷⣤⡀⠀⠀⢀⡀⠻⣿⣿⣿⣿⣦⡙⢧⠀⠀⠀⣼⠀⠀⢻⣷⡦⡄⠀⠀⠀⠈⠉⠛⠛⠛]],
        [[⢿⢰⣦⣤⣀⣛⠛⠛⠿⣿⡇⣻⣧⢸⣟⢿⣷⣿⣿⡆⠹⣿⣿⣿⣷⡘⡜⣿⣿⣿⣿⣿⣿⣿⣿⣦⡀⠙⢿⣷⡈⢿⣿⣿⣿⣿⣌⡃⠀⠀⠙⠀⢀⡾⠋⣹⣿⠀⠀⠀⠀⠀⠙⠢⢤]],
        [[⣠⣾⣿⣟⣛⣉⣉⣉⣉⣀⠀⢸⣿⡈⠛⠳⠾⠿⢿⣿⣄⠸⣿⣿⣿⣿⡄⠈⢿⣿⣿⣿⣿⣿⣿⣿⣿⠄⠀⠙⣿⣄⢻⣿⣿⣿⣿⣿⣷⣄⠀⠠⠟⠀⠀⣿⠏⢀⣾⣷⠄⠀⠀⠀⠀]],
        [[⣿⡏⠛⠛⠛⠻⢿⣿⣿⣯⣅⠘⣿⣧⠀⠈⠉⡑⠀⠈⠙⠂⢼⣿⣿⣿⣿⣦⡈⠻⣿⣿⣿⣿⣿⣿⣿⣷⣄⠀⠹⣿⡆⢻⣿⣿⣿⣿⣿⣿⣷⣄⠀⠀⠘⡏⠀⠞⠋⠀⢀⠀⠀⠀⠀]],
        [[⣿⣿⣿⣶⣦⣤⣀⣀⠈⠛⠻⢧⠙⣿⡦⠀⠀⠀⣾⣿⣷⠄⠀⠙⠻⠏⣩⣤⣬⢱⣌⡛⣿⣿⣿⣿⣿⣿⣿⣧⠀⠁⠼⠆⢻⣿⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠐⠁⠀⠀⢀⠀]],
      }
      return opts
    end,
  },

  -- You can disable default plugins as follows:
  {
    "max397574/better-escape.nvim",
    enabled = true,
  },

  -- You can also easily customize additional setup of plugins that is outside of the plugin's setup call
  {
    "L3MON4D3/LuaSnip",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.luasnip"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom luasnip configuration such as filetype extend or custom snippets
      local luasnip = require "luasnip"
      luasnip.filetype_extend("javascript", { "javascriptreact" })
    end,
  },

  {
    "windwp/nvim-autopairs",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom autopairs configuration such as custom rules
      local npairs = require "nvim-autopairs"
      local Rule = require "nvim-autopairs.rule"
      local cond = require "nvim-autopairs.conds"
      npairs.add_rules(
        {
          Rule("$", "$", { "tex", "latex" })
            -- don't add a pair if the next character is %
            :with_pair(cond.not_after_regex "%%")
            -- don't add a pair if  the previous character is xxx
            :with_pair(
              cond.not_before_regex("xxx", 3)
            )
            -- don't move right when repeat character
            :with_move(cond.none())
            -- don't delete if the next character is xx
            :with_del(cond.not_after_regex "xx")
            -- disable adding a newline when you press <cr>
            :with_cr(cond.none()),
        },
        -- disable for .vim files, but it work for another filetypes
        Rule("a", "a", "-vim")
      )
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
  {
    "tpope/vim-abolish",
    event = "VeryLazy",
  },
  {
    "stevearc/conform.nvim",
    opts = {},
    config = function()
      require("conform").setup {
        formatters_by_ft = {
          lua = { "stylua" },
          -- Conform will run multiple formatters sequentially
          python = { "isort", "black" },
          -- Use a sub-list to run only the first available formatter
          javascript = { { "prettier", "prettierd" }, "eslint" },
          typescript = { { "prettier", "prettierd" }, "eslint" },
        },
      }
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*",
        callback = function(args) require("conform").format { bufnr = args.buf } end,
      })
    end,
  },
  -- for nvim-bqf
  { "junegunn/fzf", run = function() vim.fn["fzf#install"]() end },
}
