local opt = vim.opt

vim.g.mapleader = " "
vim.g.borderStyle = "rounded"

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
