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
					add = "sa",
					find = "sf",
					replace = "sr",
					delete = "sd",
					highlight = "sh",
				},
			})
		end,
	},
	{
		"theprimeagen/harpoon",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			local map = vim.keymap.set
			map("n", "<leader>ha", ":lua require('harpoon.mark').add_file()<CR>")
			map("n", "<leader>hf", ":lua require('harpoon.ui').toggle_quick_menu()<CR>")
			map("n", "<leader>h1", ":lua require('harpoon.ui').nav_file(1)<CR>")
			map("n", "<leader>h2", ":lua require('harpoon.ui').nav_file(2)<CR>")
			map("n", "<leader>h3", ":lua require('harpoon.ui').nav_file(3)<CR>")
			map("n", "<leader>h4", ":lua require('harpoon.ui').nav_file(4)<CR>")
			map("n", "<leader>h5", ":lua require('harpoon.ui').nav_file(5)<CR>")
			require("harpoon").setup({})
		end,
	},
}
