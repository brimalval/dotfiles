return {
	"mistweaverco/kulala.nvim",
	keys = {
		{
			"<leader>Rs",
			function()
				require("kulala").run()
			end,
			desc = "Send request",
		},
		{
			"<leader>Ra",
			function()
				require("kulala").run_all()
			end,
			desc = "Send all requests",
		},
		{
			"<leader>Rb",
			function()
				require("kulala").replay()
			end,
			desc = "Replay last request",
		},
		{
			"]r",
			function()
				require("kulala").jump_next()
			end,
			desc = "Next request",
		},
		{
			"[r",
			function()
				require("kulala").jump_prev()
			end,
			desc = "Previous request",
		},
	},
	ft = { "http", "rest" },
	opts = {
		-- your configuration comes here
		global_keymaps = false,
	},
}
