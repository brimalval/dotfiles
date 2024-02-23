-- Mapping data with "desc" stored directly by vim.keymap.set().
--
-- Please use this mappings table to set keyboard mapping since this is the
-- lower level configuration and more robust one. (which-key will
-- automatically pick-up stored data by this setting.)
return {
  -- first key is the mode
  n = {
    -- second key is the lefthand side of the map

    -- navigate buffer tabs with `H` and `L`
    -- L = {
    --   function() require("astronvim.utils.buffer").nav(vim.v.count > 0 and vim.v.count or 1) end,
    --   desc = "Next buffer",
    -- },
    -- H = {
    --   function() require("astronvim.utils.buffer").nav(-(vim.v.count > 0 and vim.v.count or 1)) end,
    --   desc = "Previous buffer",
    -- },

    -- mappings seen under group name "Buffer"
    ["<leader>bD"] = {
      function()
        require("astronvim.utils.status").heirline.buffer_picker(
          function(bufnr) require("astronvim.utils.buffer").close(bufnr) end
        )
      end,
      desc = "Pick to close",
    },
    ["<C-d>"] = { "<C-d>zz", desc = "Save without formatting" },
    ["<leader>sf"] = { "<cmd> noa w <CR>", desc = "Save without formatting" },
    ["<leader>N"] = { "<cmd>lua require('notify').dismiss { silent = true }<CR>", desc = "Clear notifications" },
    ["<leader>sw"] = {
      "<cmd>set shiftwidth=4<CR>",
      desc = "Set shiftwidth to 4 (Hacky, added since current nvim config keeps re-setting the shiftwidth somewhere)",
    },
    ["<leader>G"] = {
      "<cmd>G<CR>",
      desc = "Open git fugitive",
    },
    ["<leader>fR"] = {
      "<cmd>Telescope resume<CR>",
      desc = "Reopen last Telescope search",
    },
    ["<leader>td"] = { "<Cmd> TroubleToggle document_diagnostics <CR>", desc = "Get current document diagnostics" },
    ["<leader>tD"] = { "<Cmd> TroubleToggle workspace_diagnostics <CR>", desc = "Get current workspace diagnostics" },
    -- tables with the `name` key will be registered with which-key if it's installed
    -- this is useful for naming menus
    -- ["<leader>b"] = { name = "Buffers" },
    -- quick save
    -- ["<C-s>"] = { ":w!<cr>", desc = "Save File" },  -- change description but the same command
  },
  t = {
    -- setting a mapping to false will disable it
    -- ["<esc>"] = false,
  },
  i = {
    ["<C-n>"] = { "<Cmd> call codeium#CycleCompletions(1) <CR>", desc = "Get next suggestion" },
    ["<C-b>"] = { "<Cmd> call codeium#CycleCompletions(-1) <CR>", desc = "Get previous suggestion" },
  },
}
