-- Keymaps
local map = vim.keymap.set
-- Jumps

local lsps = {
	"lua_ls",
	"pyright",
	"typos_lsp",
	"ts_ls",
	"prismals",
	"eslint",
	"tailwindcss",
}
local formatters = {
	"black",
	"isort",
	"prettier",
	"eslint-lsp",
	"sleek",
	"eslint_d",
	"prettierd",
	"markdown-toc",
}

map("n", "<Leader>c", "", { desc = "Code-related functions" })
map("n", "<Leader>cr", function()
	vim.lsp.buf.rename()
end, { desc = "Rename symbol" })
map("n", "<Leader>ca", function()
	vim.lsp.buf.code_action()
end, { desc = "Code actions" })
map("n", "<Leader>cf", function()
	local _, conform = pcall(require, "conform")
	conform.format()
end, { desc = "Format buffer" })
map("n", "<Leader>cd", function()
	vim.diagnostic.open_float()
end, { desc = "Show diagnostics" })

map("n", "<Leader>cp", function()
	vim.fn.setreg("+", vim.fn.expand("%:~:."))
end, { desc = "File path relative to project root to clipboard" })

map("n", "<Leader>cP", function()
	vim.fn.setreg("+", vim.fn.expand("%"))
end, { desc = "File path relative to root to clipboard" })

-- Configure diagnostics
vim.diagnostic.config({
	virtual_text = false,
	float = { border = vim.g.borderStyle },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "",
			[vim.diagnostic.severity.INFO] = "",
			[vim.diagnostic.severity.HINT] = "",
		},
	},
})

return {
	-- Automatically setup Lua language server for Neovim
	{
		"folke/lazydev.nvim",
		ft = "lua", -- only load on lua files
		opts = {
			library = {
				-- See the configuration section for more details
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			{ "williamboman/mason.nvim", opts = { ui = { border = vim.g.borderStyle } } },
		},
		config = function()
			local keymap = vim.keymap

			keymap.set("n", "<leader>m", "<cmd>Mason<cr>")

			require("mason-lspconfig").setup({
				ensure_installed = lsps,
				automatic_installation = true,
				automatic_enable = true,
			})
			-- Deprecated
			-- require("mason-lspconfig").setup_handlers({
			-- 	function(server_name)
			-- 		require("lspconfig")[server_name].setup({})
			-- 	end,
			-- })
		end,
	},
	"neovim/nvim-lspconfig",
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPre", "BufNewFile" },
		build = ":TSUpdate",
		config = function()
			local treesitter = require("nvim-treesitter.configs")

			---@diagnostic disable-next-line: missing-fields
			treesitter.setup({
				highlight = {
					enable = true,
				},
				indent = { enable = true },
				ensure_installed = {
					"bash",
					"c",
					"cpp",
					"css",
					"dockerfile",
					"gitignore",
					"html",
					"http",
					"javascript",
					"json",
					"lua",
					"markdown",
					"markdown_inline",
					"prisma",
					"python",
					"query",
					"rust",
					"sql",
					"toml",
					"tsx",
					"typescript",
					"vim",
					"yaml",
					"latex",
					"norg",
					"scss",
					"svelte",
					"typst",
					"vue",
				},
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<CR>",
						node_incremental = "<CR>",
						scope_incremental = false,
						node_decremental = "<BS>",
					},
				},
			})
		end,
	},

	-- {
	-- 	"copilotlsp-nvim/copilot-lsp",
	-- 	dependencies = { "github/copilot.vim" },
	-- 	init = function()
	-- 		vim.g.copilot_nes_debounce = 500
	-- 		vim.lsp.enable("copilot")
	-- 		vim.keymap.set("n", "<tab>", function()
	-- 			require("copilot-lsp.nes").apply_pending_nes()
	-- 		end)
	-- 	end,
	-- },
	{
		"copilotlsp-nvim/copilot-lsp",
		dependencies = { "zbirenbaum/copilot.lua" },
		init = function()
			vim.g.copilot_nes_debounce = 300
			vim.lsp.enable("copilot_ls")
			-- vim.keymap.set({ "n", "v" }, "<M-a>", function()
			-- 	local _ = (
			-- 		require("copilot-lsp.nes").apply_pending_nes() and require("copilot-lsp.nes").walk_cursor_end_edit()
			-- 	)
			-- end)
			vim.keymap.set("n", "<M-\\>", function()
				local copilot_lsp_client = vim.lsp.get_clients({ name = "copilot_ls" })[1]
				require("copilot-lsp.nes").request_nes(copilot_lsp_client)
			end)
		end,
	},
}
