local OBSIDIAN_VAULT = vim.fn.expand("~") .. "/Projects/Zettelkasten"
local ARCHIVES_FOLDER = OBSIDIAN_VAULT .. "/400. Archive"
return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
		-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {},
	},
	{
		"obsidian-nvim/obsidian.nvim",
		version = "*", -- recommended, use latest release instead of latest commit
		lazy = true,
		ft = "markdown",
		-- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
		-- event = {
		--   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
		--   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
		--   -- refer to `:h file-pattern` for more examples
		--   "BufReadPre path/to/my-vault/*.md",
		--   "BufNewFile path/to/my-vault/*.md",
		-- },
		dependencies = {
			-- Required.
			"nvim-lua/plenary.nvim",

			-- see below for full list of optional dependencies 👇
		},
		opts = {
			mappings = {
				["<leader>A"] = {
					action = function()
						local result = vim.fn.system({
							"mv",
							vim.fn.expand("%"),
							ARCHIVES_FOLDER,
						})
						if vim.v.shell_error ~= 0 then
							print("Error moving file: " .. result)
						else
							print("Archived" .. vim.fn.expand("%:t"))
						end
					end,
					opts = { noremap = false, desc = "Archive note" },
				},
				["gf"] = {
					action = function()
						return require("obsidian").util.gf_passthrough()
					end,
					opts = { noremap = false, expr = true, buffer = true },
				},
				-- Toggle check-boxes.
				["<leader>ch"] = {
					action = function()
						return require("obsidian").util.toggle_checkbox()
					end,
					opts = { buffer = true },
				},
				-- Smart action depending on context, either follow link or toggle checkbox.
				["<cr>"] = {
					action = function()
						return require("obsidian").util.smart_action()
					end,
					opts = { buffer = true, expr = true },
				},
			},
			workspaces = {
				{
					name = "Zettelkasten",
					path = OBSIDIAN_VAULT,
				},
			},
			config = {
				ui = {
					enable = false,
				},
			},
			completion = {
				blink = true,
			},
		},
	},
	{
		"HakonHarnes/img-clip.nvim",
		event = "VeryLazy",
		opts = {
			-- add options here
			-- or leave it empty to use the default settings
		},
		keys = {
			-- suggested keymap
			{ "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
			{
				"<leader>P",
				function()
					Snacks.picker.files({
						ft = { "jpg", "jpeg", "png", "webp" },
						confirm = function(self, item, _)
							self:close()
							require("img-clip").paste_image({}, "./" .. item.file) -- ./ is necessary for img-clip to recognize it as path
						end,
					})
				end,
				desc = "Paste image from picker",
			},
		},
	},
}
