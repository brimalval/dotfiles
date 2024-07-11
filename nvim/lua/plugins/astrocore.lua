-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend settig up the Lua Language Server (lua_ls) as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 100, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
      diagnostics_mode = 2, -- diagnostic mode on start (0 = off, 1 = no signs/virtual text, 2 = no virtual text, 3 = on)
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "auto", -- sets vim.opt.signcolumn to auto
        wrap = true, -- sets vim.opt.wrap
        swapfile = false, -- sets vim.opt.swapfile
        conceallevel = 2,
        showtabline = 0,
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
        python3_host_prog = "/usr/local/python3-neovim-provider/.venv/bin/python",
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        -- navigate buffer tabs with `H` and `L`
        -- L = {
        --   function() require("astrocore.buffer").nav(vim.v.count > 0 and vim.v.count or 1) end,
        --   desc = "Next buffer",
        -- },
        -- H = {
        --   function() require("astrocore.buffer").nav(-(vim.v.count > 0 and vim.v.count or 1)) end,
        --   desc = "Previous buffer",
        -- },

        -- mappings seen under group name "Buffer"
        ["<Leader>bD"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Pick to close",
        },
        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        ["<Leader>b"] = { desc = "Buffers" },
        -- quick save
        -- ["<C-s>"] = { ":w!<cr>", desc = "Save File" },  -- change description but the same command
        ["<Leader>G"] = { "<Cmd>Git<CR>", desc = "Open Git fugitive" },
        ["<leader>sd"] = { "<cmd> noa w <CR>", desc = "Save without formatting" },
        ["<leader>td"] = { "<Cmd> TroubleToggle document_diagnostics <CR>", desc = "Get current document diagnostics" },
        ["<leader>tD"] = {
          "<Cmd> TroubleToggle workspace_diagnostics <CR>",
          desc = "Get current workspace diagnostics",
        },
        ["<leader><leader>a"] = { function() require("harpoon"):list():add() end, desc = "Mark in harpoon" },
        ["yB"] = { "<Cmd> let @+ = expand('%:p') <CR>", desc = "Yank current file's path" },
        ["<leader>fR"] = { function() require("telescope.builtin").lsp_references() end, desc = "Search references" },
      },
      t = {
        -- setting a mapping to false will disable it
        -- ["<esc>"] = false,
      },
      i = {
        ["<Tab>"] = false,
        ["<C-k>"] = nil,
      },
    },
    autocmds = {
      set_python_indent = {
        {
          event = "BufEnter",
          -- Run if filetype is python
          desc = "Set Python indent level to 4",
          callback = function()
            if vim.bo.filetype == "python" then
              vim.opt_local.tabstop = 4
              vim.opt_local.shiftwidth = 4
              vim.opt_local.softtabstop = 4
              vim.opt_local.expandtab = true
            end
          end,
        },
      },
    },
  },
}
