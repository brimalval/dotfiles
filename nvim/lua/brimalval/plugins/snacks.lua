return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type function|snacks.Config
	opts = function()
		local keymap = vim.keymap
		Snacks = require("snacks")

		keymap.set("n", "<leader>e", function()
			Snacks.explorer.open()
		end, { desc = "Open file explorer" })

		keymap.set("n", "<leader>ff", function()
			Snacks.picker.files()
		end, { desc = "Open file picker" })

		keymap.set("n", "<leader>fc", function()
			Snacks.picker.files({
				title = "Configs",
				cwd = "~/.config/nvim",
			})
		end, { desc = "Search configs" })

		keymap.set("n", "<leader>fF", function()
			Snacks.picker.files({
				hidden = true,
			})
		end, { desc = "Open file picker (including hidden files)" })

		keymap.set("n", "<leader>fg", function()
			Snacks.picker.grep()
		end, { desc = "Open file grepper" })

		keymap.set("n", "<leader>fG", function()
			Snacks.picker.grep({ hidden = true })
		end, { desc = "Open file grepper (including hidden files)" })

		keymap.set("n", "<leader>fb", function()
			Snacks.picker.buffers()
		end, { desc = "Open buffer picker" })

		keymap.set("n", "<leader>fd", function()
			Snacks.picker.diagnostics()
		end, { desc = "Open diagnostics picker" })

		keymap.set("n", "<leader>fD", function()
			Snacks.picker.diagnostics({
				-- Only works in Neovim 0.10+
				cwd = vim.fs.root(0, ".git"),
			})
		end, { desc = "Open workspace diagnostics picker" })

		return {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
			bigfile = { enabled = true },
			dashboard = { enabled = true },
			explorer = { enabled = true },
			image = { enabled = true },
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
