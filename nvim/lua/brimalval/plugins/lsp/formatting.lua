return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	keys = {
		{
			"<leader>cf",
			function()
				require("conform").format()
			end,
			mode = "n",
			desc = "Format code with conform",
		},
	},
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		{
			"williamboman/mason.nvim",
			opts = {
				ensure_installed = {
					"black",
					"isort",
					"prettier",
					"eslint-lsp",
					"sleek",
					"eslint_d",
					"prettierd",
					"markdown-toc",
				},
			},
		},
	},
	opts = {
		formatters_by_ft = {
			sql = { "sleek" },
			python = { "isort", "black" },
			typescript = { "prettier", "eslint_d" },
			typescriptreact = { "prettier", "eslint_d" },
			javascript = { "prettier", "eslint_d" },
			lua = { "stylua" },
			http = { "kulala-fmt" },
			markdown = { "prettierd", "markdown-toc" },
		},
		format_on_save = {
			lsp_fallback = true,
		},
		formatters = {
			black = {
				prepend_args = { "--line-length", "79", "--skip-string-normalization" },
			},
		},
	},
}
