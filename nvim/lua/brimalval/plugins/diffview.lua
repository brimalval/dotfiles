return {
	"sindrets/diffview.nvim",
	dependencies = {
		-- For the Snacks toggle
		"folke/snacks.nvim",
	},
	event = "VeryLazy",
	config = function()
		require("diffview").setup()
		Snacks.toggle({
			name = "Diffview",
			get = function()
				return require("diffview.lib").get_current_view() ~= nil
			end,
			set = function(state)
				vim.cmd("Diffview" .. (state and "Open" or "Close"))
			end,
		}):map("<leader>gD")
	end,
}
