-- Keymaps
local map = vim.keymap.set
-- Jumps

local lsps = {
	"lua_ls",
	"basedpyright",
	"typos_lsp",
	"ts_ls",
	"prismals",
	"eslint",
	"tailwindcss",
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
			"neovim/nvim-lspconfig",
		},
		config = function()
			local keymap = vim.keymap

			keymap.set("n", "<leader>m", "<cmd>Mason<cr>")

			local function project_python(root_dir)
				if not root_dir then
					return nil
				end

				for _, path in ipairs({ root_dir .. "/.venv/bin/python", root_dir .. "/venv/bin/python" }) do
					if vim.fn.executable(path) == 1 then
						return path
					end
				end
			end

			vim.lsp.config("basedpyright", {
				settings = {
					basedpyright = {
						analysis = {
							autoImportCompletions = true,
						},
					},
				},
				before_init = function(_, config)
					local python = project_python(config.root_dir)
					if python then
						config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
							python = { pythonPath = python },
						})
					end
				end,
			})

			-- Root Ruby LSPs at the nearest Gemfile rather than the repo-root
			-- .git, so Bundler-backed servers (solargraph) don't crash with
			-- `Bundler::GemfileNotFound` in monorepos where the app lives in a
			-- subdirectory (e.g. backend/Gemfile).
			local function gemfile_root(bufnr, on_dir)
				local fname = vim.api.nvim_buf_get_name(bufnr)
				on_dir(vim.fs.root(fname, { "Gemfile", ".solargraph.yml" }))
			end

			vim.lsp.config("ruby_lsp", {
				cmd = { "bundle", "exec", "ruby-lsp" },
				root_dir = gemfile_root,
			})

			require("mason-lspconfig").setup({
				ensure_installed = lsps,
				automatic_enable = lsps,
			})

			vim.lsp.enable("ruby_lsp")
		end,
	},
	{
		-- main branch (the rewrite; master is frozen and breaks on nvim 0.12). It only installs parsers and
		-- queries: highlighting, indent and selection are switched on below with nvim's own treesitter API.
		-- Needs the tree-sitter CLI and a C compiler on PATH (nix/home.nix, nix/home-nixos-wsl.nix).
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false, -- main doesn't support lazy-loading
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").install({
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
				"scss",
				"svelte",
				"typst",
				"vue",
			})

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("brimalval_treesitter", { clear = true }),
				callback = function(args)
					-- No parser for this filetype: leave the buffer alone (regex syntax, default indent, <CR> as usual).
					if not pcall(vim.treesitter.start, args.buf) then
						return
					end
					vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

					-- Incremental selection, as before: <CR> starts and grows it, <BS> shrinks it.
					-- Calls what nvim 0.12's built-in visual `an`/`in` call: mini.ai takes over those keys
					-- ("around/inside next"), so mapping to the keys would reach mini.ai instead.
					-- vim.treesitter._select is internal; if a newer nvim renames it, look at `:verbose xmap an`
					-- with mini.ai disabled.
					local select = require("vim.treesitter._select")
					local map = function(mode, lhs, rhs, desc)
						vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, desc = desc })
					end
					map("n", "<CR>", function()
						vim.cmd("normal! v")
						select.select_parent(vim.v.count1)
					end, "Start treesitter selection")
					map("x", "<CR>", function()
						select.select_parent(vim.v.count1)
					end, "Grow treesitter selection")
					map("x", "<BS>", function()
						select.select_child(vim.v.count1)
					end, "Shrink treesitter selection")
				end,
			})
		end,
	},
}
