return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	priority = 1000,
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
		delay = 0,
		preset = "modern",
		win = {
			height = { min = 8, max = 15 },
		},
	},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
	},
}
