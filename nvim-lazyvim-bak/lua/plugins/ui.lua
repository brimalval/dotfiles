-- if true then
--   return {}
-- end
-- local icons = LazyVim.config.icons

return {
  -- Startup text (deprecated)
  --   {
  --     "nvimdev/dashboard-nvim",
  --     opts = function(_, opts)
  --       local logo = [[
  --                  __         _                                            _
  --  _ __ ___  ___  /_/   _ __ (_)_ __   ___           _ __   ___  _____   _(_)_ __ ___
  -- | '__/ _ \/ __|/ _ \ | '_ \| | '_ \ / _ \  _____  | '_ \ / _ \/ _ \ \ / / | '_ ` _ \
  -- | | | (_) \__ \  __/ | |_) | | | | |  __/ |_____| | | | |  __/ (_) \ V /| | | | | | |
  -- |_|  \___/|___/\___| | .__/|_|_| |_|\___|         |_| |_|\___|\___/ \_/ |_|_| |_| |_|
  --                      |_|
  --   ]]
  --       logo = string.rep("\n", 8) .. logo .. "\n\n"
  --
  --       -- table.insert(logo, "\n\n")
  --
  --       opts["config"]["header"] = vim.split(logo, "\n")
  --     end,
  --   },
  -- Add borders to floating completion windows
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        sections = {
          { section = "header" },
          {
            pane = 2,
            section = "terminal",
            cmd = "colorscript -e square",
            height = 5,
            padding = 1,
          },
          { section = "keys", gap = 1, padding = 1 },
          { pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
          { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
          {
            pane = 2,
            icon = " ",
            title = "Git Status",
            section = "terminal",
            enabled = function()
              return Snacks.git.get_root() ~= nil
            end,
            cmd = "hub status --short --branch --renames",
            height = 5,
            padding = 1,
            ttl = 5 * 60,
            indent = 3,
          },
          { section = "startup" },
        },
      },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    ---@param opts cmp.ConfigSchema
    opts = {
      window = {
        completion = {
          border = "single",
        },
        documentation = {
          border = "single",
        },
      },
    },
  },
  -- Remove bufferline
  -- {
  --   "akinsho/bufferline.nvim",
  --   enabled = false,
  -- },
  -- Lualine config; remove nvim-navic integration
  -- nvim-navic shows context
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      -- nvim-navic is added last. Remove it from the statusline
      table.remove(opts.sections.lualine_c)
      -- Remove the pretty-path and the filetype too
      table.remove(opts.sections.lualine_c)
      table.remove(opts.sections.lualine_c)
    end,
  },
  -- Use barbecue for context instead
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
  },
}
