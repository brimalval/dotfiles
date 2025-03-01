-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Keymaps are automatically loaded on the VeryLazy event
-- Add any additional keymaps here
local map = vim.keymap.set

-- Example:
-- map(
--   "n",
--   "<Leader>cz",
--   require("telescope.builtin").lsp_references,
--   { desc = "Telescope References", noremap = true, silent = true }
-- )

-- local map = vim.keymap.set
-- map("n", "<Cmd> !python ")
map("n", "<Leader>fa", function()
  -- Exclude node_modules
  require("telescope.builtin").find_files({
    find_command = { "rg", "--ignore", "--hidden", "--files", "-u", "--glob", "!node_modules/**" },
  })
end, { desc = "Find Files (including hidden files)", noremap = true, silent = true })

-- LazyVim already binds this but it filters too much
map("n", "<Leader>ss", function()
  require("telescope.builtin").lsp_document_symbols()
end)

map("n", "<Leader>z", "<Cmd> ZenMode <CR>", { desc = "Toggle Zen Mode", noremap = true, silent = true })
map("n", "<Leader>uD", "<Cmd> DBUI <CR>", { desc = "Enter DBUI", noremap = true, silent = true })
map("n", "<Leader>G", "<Cmd> G <CR>", { desc = "Git fugitive", noremap = true, silent = true })

function YankAndOpenTerminal()
  -- print("hello world")
  local manager = require("neo-tree.sources.manager")
  local state = manager.get_state("filesystem")
  local path = state.get_node()

  if state then
    -- local file_path = node:unpack()
    -- vim.fn.setreg("+", file_path)
    -- vim.cmd("vsplit term://")
    print(path)
  else
    print("No node selected")
  end
end
--
-- map("n", "<Leader>xd", [[:lua YankAndOpenTerminal()<CR>]], { noremap = true, silent = true })
