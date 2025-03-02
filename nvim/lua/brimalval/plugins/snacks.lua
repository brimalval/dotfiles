return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = function()
		local keymap = vim.keymap
		Snacks = require("snacks")

		keymap.set("n", "<leader>e", function()
			Snacks.explorer.open()
		end, { desc = "Open Snacks explorer" })

		keymap.set("n", "<leader>ff", function()
			Snacks.picker.files()
		end, { desc = "Open Snacks file picker" })

		return {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
			bigfile = { enabled = true },
			dashboard = { enabled = true },
			explorer = { enabled = true },
			indent = { enabled = true },
			input = { enabled = true },
			picker = { enabled = true },
			notifier = { enabled = true },
			quickfile = { enabled = true },
			scope = { enabled = true },
			scroll = { enabled = false },
			statuscolumn = { enabled = true },
			words = { enabled = true },
		}
	end,
}
