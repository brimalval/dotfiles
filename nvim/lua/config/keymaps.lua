-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set

-- Example:
-- map(
--   "n",
--   "<Leader>cz",
--   require("telescope.builtin").lsp_references,
--   { desc = "Telescope References", noremap = true, silent = true }
-- )

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
