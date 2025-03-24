return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		options = {
			theme = "rose-pine",
			icons_enabled = true,
			always_divide_middle = true,
			component_separators = { left = "", right = "" },
			section_separators = { left = "", right = "" },
		},
		sections = {
			lualine_a = {
				{
					function()
						return " "
					end,
					padding = 0,
				},
			},
			lualine_x = {
				"encoding",
				"fileformat",
				"filetype",
				-- components available to noice: ruler, message, command, mode, search
				{
					require("noice").api.status.command.get,
					cond = require("noice").api.status.command.has,
				},
				-- don't show mode text
				{
					require("noice").api.status.mode.get_hl,
					cond = function()
						local Noice = require("noice")
						local mode = Noice.api.status.mode.get()
						local pattern = "%-%- (.-) %-%-"
						local allow = true

						if mode ~= nil then
							local match = string.match(mode, pattern)
							allow = match == nil
						end
						return Noice.api.status.mode.has() and allow
					end,
				},
			},
			lualine_z = {
				{
					function()
						return " "
					end,
					padding = 0,
				},
			},
		},
	},
}
