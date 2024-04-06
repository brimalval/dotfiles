local M = {}

M.general = {
  n = {
    ["<leader>ha"] = {
      function()
        local harpoon_mark = require "harpoon.mark"
        harpoon_mark.add_file()
      end,
      "Harpoon: Add a file",
    },
    ["<leader>hu"] = {
      function()
        local harpoon_ui = require "harpoon.ui"
        harpoon_ui.toggle_quick_menu()
      end,
      "Harpoon: Show marked files",
    },
    ["<leader>sf"] = { "<cmd> noa w <CR>", "Save without formatting" },
    ["<leader>xa"] = { '<cmd> %bdelete|edit|normal `" <CR>', "Close all buffers except the current one" },
    ["<leader>xf"] = { '<cmd> %bdelete!|edit|normal `" <CR>', "Close all buffers except the current one (force)" },
    ["<leader>gf"] = { "<cmd> G <CR>", "Open git-fugitive" },
    ["<leader>S"] = { "<cmd>lua require('spectre').open()<CR>", "Open Spectre" },
    ["<leader>sw"] = { "<cmd>lua require('spectre').open_visual({select_word=true})<CR>", "Search current word" },
    ["<leader>sp"] = {
      "<cmd>lua require('spectre').open_file_search({select_word=true})<CR>",
      "Search on current file",
    },
    ["<leader>sc"] = { "<cmd>lua require('specs').show_specs()<CR>", "Show cursor's current location" },
  },
  v = {
    ["<leader>sw"] = { "<esc><cmd>lua require('spectre').open_visual()<CR>", "Search current word" },
  },
}

M.dap = {
  plugin = true,
  n = {
    ["<leader>db"] = { "<cmd> DapToggleBreakpoint <CR>" },
  },
}

M.dap_python = {
  plugin = true,
  n = {
    ["<leader>dpr"] = {
      function()
        require("dap-python").test_method()
      end,
    },
  },
}

M.telescope = {
  plugin = true,

  n = {
    -- find references
    ["<leader>flr"] = { "<cmd> Telescope lsp_references <CR>", "Find LSP references" },
  },
}

return M
