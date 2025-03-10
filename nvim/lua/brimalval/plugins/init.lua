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
			require("supermaven-nvim").setup({})
		end,
	},
	{
		"echasnovski/mini.surround",
		version = "*",
		config = function()
			require("mini.surround").setup({
				mappings = {
					add = "as",
					find = "fs",
					replace = "cs",
					delete = "ds",
					-- highlight = "",
				},
			})
		end,
	},
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local status_ok, harpoon = pcall(require, "harpoon")
			if not status_ok then
				return
			end
			harpoon:setup()

			-- picker
			local function generate_harpoon_picker()
				local file_paths = {}
				for _, item in ipairs(harpoon:list().items) do
					table.insert(file_paths, {
						text = item.value,
						file = item.value,
					})
				end
				return file_paths
			end
			vim.keymap.set("n", "<leader>ha", function()
				harpoon:list():add()
			end)
			vim.keymap.set("n", "<leader>hl", function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end)
			vim.keymap.set("n", "<leader>fh", function()
				Snacks.picker({
					finder = generate_harpoon_picker,
					title = "Harpoon Files",
					win = {
						input = { keys = {
							["dd"] = { "harpoon_delete", mode = { "n", "x" } },
						} },
						list = {
							keys = {
								["dd"] = { "harpoon_delete", mode = { "n", "x" } },
							},
						},
					},
					actions = {
						harpoon_delete = function(picker, item)
							local to_remove = item or picker:selected()
							table.remove(harpoon:list().items, to_remove.idx)
							picker:find({
								refresh = true, -- refresh picker after removing values
							})
						end,
					},
				})
			end)
		end,
	},
	{
		"aserowy/tmux.nvim",
		config = function()
			require("tmux").setup({
				-- your configuration comes here
				-- or leave it empty to use the default settings
				-- refer to the configuration section below
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
}
