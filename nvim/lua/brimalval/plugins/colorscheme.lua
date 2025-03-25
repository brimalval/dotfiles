return {
	{
		"rose-pine/neovim",
		name = "rose-pine",
		config = function()
			local palette = require("rose-pine.palette")
			require("rose-pine").setup({
				variant = "moon",
				styles = {
					transparency = true,
					italics = true,
				},
				highlight_groups = {
					CursorLineNr = {
						fg = palette.foam,
					},
				},
			})
			vim.cmd([[colorscheme rose-pine-moon]])
		end,
	},
	{ "folke/tokyonight.nvim", lazy = false, priority = 1000, opts = {} },
}
