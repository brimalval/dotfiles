local find_git_root = require("brimalval.core.utils").find_git_root
local is_biome_present = vim.uv.fs_stat(find_git_root() .. "/biome.json") and true or false

return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	keys = {
		{
			"<leader>cf",
			function()
				require("conform").format({ async = true, lsp_fallback = true })
			end,
			mode = "n",
			desc = "Format code with conform",
		},
	},
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		{
			"williamboman/mason.nvim",
		},
	},
	config = function()
		local util = require("conform.util")

		require("conform").setup({
			formatters_by_ft = {
				sql = { "sleek" },
				python = { "isort", "black" },
				typescript = { "prettier", "eslint_d", "biome" },
				javascript = { "prettier", "eslint_d", "biome" },
				typescriptreact = { "prettier", "eslint_d", "biome" },
				javascriptreact = { "prettier", "eslint_d", "biome" },
				lua = { "stylua" },
				http = { "kulala" },
				markdown = { "prettierd", "markdown-toc" },
			},
			format_on_save = {
				lsp_fallback = true,
			},
			formatters = {
				black = {
					prepend_args = { "--line-length", "79", "--skip-string-normalization" },
				},
				kulala = {
					command = "kulala-fmt",
					args = { "format", "$FILENAME" },
					stdin = false,
				},
				prettier = {
					condition = function()
						return not is_biome_present
					end,
				},
				eslint_d = {
					command = util.from_node_modules("eslint_d"),
					args = { "--fix-to-stdout", "--stdin", "--stdin-filename", "$FILENAME" },
					condition = function()
						return not is_biome_present
					end,
				},
				biome = {
					command = util.from_node_modules("biome"),
					stdin = true,
					args = { "check", "--write", "--stdin-file-path", "$FILENAME" },
					condition = function()
						return is_biome_present
					end,
				},
			},
		})
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = vim.api.nvim_create_augroup("EslintFixAll", { clear = true }),
			pattern = { "*.tsx", "*.ts", "*.jsx", "*.js" },
			command = "silent! EslintFixAll",
		})
	end,
}
