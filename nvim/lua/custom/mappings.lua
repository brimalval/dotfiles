local M = {}

M.general = {
  i = {
    -- map switch to normal mode to jj
    ["jj"] = { "<ESC>", "Switch to normal mode"}
  },
  n = {
    ["<leader>ha"] = {
      function ()
        harpoon_mark = require("harpoon.mark")   
        harpoon_mark.add_file()
      end,
      "Harpoon: Add a file"
    },
    ["<leader>hu"] = {
      function ()
        harpoon_ui = require("harpoon.ui")
        harpoon_ui.toggle_quick_menu()
      end,
      "Harpoon: Show marked files"
    }
  }
}

M.dap = {
  plugin = true,
  n = {
    ["<leader>db"] = {"<cmd> DapToggleBreakpoint <CR>"}
  }
}

M.dap_python = {
  plugin = true,
  n = {
    ["<leader>dpr"] = {
      function()
        require('dap-python').test_method()
      end
    }
  }
}

M.telescope = {
  plugin = true,

  n = {
    -- find references
    ["<leader>flr"] = { "<cmd> Telescope lsp_references <CR>", "Find LSP references" },
  },
}

return M
