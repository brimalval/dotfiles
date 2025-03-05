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
		"theprimeagen/harpoon",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			local map = vim.keymap.set
      -- stylua: ignore
			map("n", "<leader>ha", ":lua require('harpoon.mark').add_file()<CR>", { desc = "Add file to harpoon" })
			map(
				"n",
				"<leader>hf",
				":lua require('harpoon.ui').toggle_quick_menu()<CR>",
				{ desc = "Toggle harpoon quick menu" }
			)
			map("n", "<leader>h1", ":lua require('harpoon.ui').nav_file(1)<CR>", { desc = "Go to file 1" })
			map("n", "<leader>h2", ":lua require('harpoon.ui').nav_file(2)<CR>", { desc = "Go to file 2" })
			map("n", "<leader>h3", ":lua require('harpoon.ui').nav_file(3)<CR>", { desc = "Go to file 3" })
			map("n", "<leader>h4", ":lua require('harpoon.ui').nav_file(4)<CR>", { desc = "Go to file 4" })
			map("n", "<leader>h5", ":lua require('harpoon.ui').nav_file(5)<CR>", { desc = "Go to file 5" })
			require("harpoon").setup({})
		end,
	},
}
