local map = vim.keymap.set

-- Example:
-- map(
--   "n",
--   "<Leader>cz",
--   require("telescope.builtin").lsp_references,
--   { desc = "Telescope References", noremap = true, silent = true }
-- )

-- Escaping
map("i", "jj", "<Esc>")
map("i", "jk", "<Esc>")

-- Buffer navigation
map("n", "<C-h>", "<C-w>h", { desc = "Move to the left buffer" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to the buffer below" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to the buffer above" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to the right buffer" })

-- Easier saving
map("i", "<c-s>", "<Nop>")
map("i", "<c-s>", "<Esc><Cmd>W<CR>", { desc = "Save file" })

-- Visual line navigation
map("n", "j", "gj")
map("n", "k", "gk")

-- Kill search highlights
map("n", "<esc>", "<Cmd>noh<CR>")
