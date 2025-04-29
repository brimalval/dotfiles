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

-- Visual line navigation
map("n", "j", "gj")
map("n", "k", "gk")

-- Better scrolling
-- map("n", "<C-u>", "<C-u>zz")
-- map("n", "<C-d>", "<C-d>zz")
map("n", "<C-e>", "jzz")
map("n", "<C-y>", "kzz")

-- Kill search highlights
map("n", "<esc>", "<Cmd>noh<CR>")

-- Select all
-- map("n", "<M-a>", "ggVG", { desc = "Select all" })

-- Save using ctrl + S
map("n", "<C-s>", ":w<CR>", { desc = "Save file" })
map("i", "<C-s>", "<Esc>:w<CR>", { desc = "Save file" })

-- Nice reindent
map("n", "==", "==w", { desc = "Reindent line" })

-- -- Bindings that get passed to better-escape.nvim
-- return {}
