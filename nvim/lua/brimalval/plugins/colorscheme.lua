return {
	{
		"rose-pine/neovim",
		name = "rose-pine",
		config = function()
			require("rose-pine").setup({
				variant = "moon",
				styles = {
					transparency = true,
					italics = true,
				},
				highlight_groups = {
					CursorLineNr = {
						fg = "#9CCFD8",
					},
				},
			})
			vim.cmd([[colorscheme rose-pine-moon]])
		end,
	},
	{ "folke/tokyonight.nvim", lazy = false, priority = 1000, opts = {} },
}
