return {
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
		-- use opts = {} for passing setup options
		-- this is equivalent to setup({}) function
	},
	{
		"supermaven-inc/supermaven-nvim",
		config = function()
			require("supermaven-nvim").setup({
				-- keymaps = {
				-- 	accept_suggestion = "<C-l>",
				-- 	clear_suggestion = "<C-]>",
				-- 	accept_word = "<C-m>",
				-- },
			})
		end,
	},
	{
		"echasnovski/mini.surround",
		version = "*",
		config = function()
			require("mini.surround").setup({
				mappings = {
					add = "gs",
					find = "fs",
					find_left = "fS",
					replace = "cs",
					delete = "ds",
					-- clear these bindings; they're not needed and they mess with
					-- flash.nvim
					update_n_lines = "",
					highlight = "",
				},
			})
		end,
	},
	{
		"aserowy/tmux.nvim",
		config = function()
			require("tmux").setup({
				-- Don't use tmuxclipboard provider
				-- allow use of the system clipboard instead
				copy_sync = {
					enable = false,
				},
			})
		end,
	},
	{
		"nvzone/typr",
		dependencies = "nvzone/volt",
		opts = {},
		cmd = { "Typr", "TyprStats" },
	},
	{
		"windwp/nvim-ts-autotag",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("nvim-ts-autotag").setup()
		end,
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		},
	},
	-- {
	-- 	"gregorias/coerce.nvim",
	-- 	tag = "v4.1.0",
	-- 	config = true,
	-- },
	-- {
	-- 	"hedyhli/outline.nvim",
	-- 	config = function()
	-- 		-- Example mapping to toggle outline
	-- 		vim.keymap.set("n", "<leader>o", "<cmd>Outline<CR>", { desc = "Toggle Outline" })
	--
	-- 		require("outline").setup({
	-- 			-- Your setup opts here (leave empty to use defaults)
	-- 		})
	-- 	end,
	-- },
	{
		"chrisbra/csv.vim",
		ft = "csv",
	},
	{
		"NvChad/nvim-colorizer.lua",
		opts = {
			user_default_options = {
				mode = "background",
				names = false,
			},
		},
	},
	{
		"folke/persistence.nvim",
		event = "BufReadPre",
		opts = {},
    -- stylua: ignore
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
      { "<leader>qS", function() require("persistence").select() end,desc = "Select Session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
    },
	},
	-- {
	-- 	"m4xshen/hardtime.nvim",
	-- 	dependencies = { "MunifTanjim/nui.nvim" },
	-- 	opts = {},
	-- },
	-- {
	-- 	"princejoogie/duckdb.nvim",
	-- 	dir = "~/Projects/duckdb.nvim",
	-- 	opts = {
	-- 		rows_per_page = 50,
	-- 	},
	-- 	ft = { "csv" },
	-- },
	{
		"MagicDuck/grug-far.nvim",
		opts = { headerMaxWidth = 80 },
		cmd = "GrugFar",
		keys = {
			{
				"<leader>sr",
				function()
					local grug = require("grug-far")
					local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
					grug.open({
						transient = true,
						prefills = {
							filesFilter = ext and ext ~= "" and "*." .. ext or nil,
						},
					})
				end,
				mode = { "n", "v" },
				desc = "Search and Replace",
			},
		},
	},
	-- {
	-- 	"chrisgrieser/nvim-origami",
	-- 	event = "VeryLazy",
	-- 	opts = {}, -- needed even when using default config
	-- },
	{
		"smjonas/live-command.nvim",
		-- live-command supports semantic versioning via Git tags
		-- tag = "2.*",
		config = function()
			require("live-command").setup({
				commands = {
					Norm = { cmd = "norm" },
					Sub = { cmd = "s/\\v" },
				},
			})
		end,
	},
	{
		"mluders/comfy-line-numbers.nvim",
		config = function()
			require("comfy-line-numbers").setup()
		end,
	},
}
