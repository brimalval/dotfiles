-- Keymaps
local map = vim.keymap.set
-- Jumps
map("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", { desc = "Go to definition" })
map("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", { desc = "Go to declaration" })
map("n", "gi", "<Cmd>lua vim.lsp.buf.implementation()<CR>", { desc = "Go to implementation" })
map("n", "gr", "<Cmd>lua vim.lsp.buf.references()<CR>", { desc = "Go to references" })
map("n", "gt", "<Cmd>lua vim.lsp.buf.type_definition()<CR>", { desc = "Go to type definition" })

map("n", "<Leader>c", "", { desc = "Code-related functions" })
map("n", "<Leader>cr", function()
	vim.lsp.buf.rename()
end, { desc = "Rename symbol" })
map("n", "<Leader>ca", function()
	vim.lsp.buf.code_action()
end, { desc = "Code actions" })
map("n", "<Leader>cf", function()
	vim.lsp.buf.format()
end, { desc = "Format buffer" })
map("n", "<Leader>cd", function()
	vim.diagnostic.open_float()
end, { desc = "Show diagnostics" })

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
				ensure_installed = {
					"lua_ls",
					"pyright",
					"typos_lsp",
					"ts_ls",
					"prismals",
				},
				automatic_installation = true,
			})
			require("mason-lspconfig").setup_handlers({
				function(server_name)
					require("lspconfig")[server_name].setup({})
				end,
			})
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
}
