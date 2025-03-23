return {
	"oskarrrrrrr/symbols.nvim",
	dependencies = {
		-- For the toggle function
		"folke/snacks.nvim",
	},
	config = function()
		local r = require("symbols.recipes")
		require("symbols").setup(r.DefaultFilters, r.AsciiSymbols, {
			sidebar = {
				open_direction = "right",
				auto_resize = {
					min_width = 250,
				},
				fixed_width = 60,
				preview = {
					show_always = true,
					-- for some reason showing line numbers breaks
					-- the line number display for your main buffer
					-- show_line_number = true,
				},
			},
			-- custom settings here
			-- e.g. hide_cursor = false
		})
		Snacks.toggle({
			name = "Symbols",
			wk_desc = {
				enabled = "",
				disabled = "",
			},
			notify = false,
			get = function()
				local ft = vim.bo.filetype
				return ft ~= "SymbolsSidebar"
			end,
			set = function(state)
				vim.cmd("" .. (state and "SymbolsClose" or "Symbols"))
			end,
		}):map("<leader>cs")
		-- vim.keymaps.set("n", "<leader>cS", "<Cmd>SymbolsClose<CR>", { desc = "Close Symbols sidebar" })
	end,
}
