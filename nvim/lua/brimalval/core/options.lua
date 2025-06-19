local opt = vim.opt

vim.g.mapleader = " "
vim.g.borderStyle = "rounded"

-- folds
-- vim.opt.foldmethod = "expr"
-- vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

-- tabs & indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true

opt.autoindent = true
opt.textwidth = 80
opt.breakindent = true

opt.wrap = false

opt.cursorline = true

-- Disable swap files
opt.swapfile = false

opt.number = true
opt.relativenumber = true

-- Case-insensitive searching
opt.ignorecase = true

-- Use system clipboard
opt.clipboard = "unnamedplus"

-- Splits
opt.splitright = true
opt.splitbelow = true

-- Remove the tildes on the side
opt.fillchars = { eob = " " }

-- Make the statusline global
opt.laststatus = 3

-- Persist undo history
opt.undofile = true
opt.undodir = vim.fn.stdpath("cache") .. "/undo"

vim.diagnostic.config({
	-- virtual_lines = {
	-- 	current_line = true,
	-- },
	virtual_text = true,
})
