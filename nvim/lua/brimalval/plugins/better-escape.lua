local escape_keymaps = {
	i = {
		j = {
			k = "<Esc>",
		},
	},
}
return {
	"max397574/better-escape.nvim",
	priority = 1000,
	config = function()
		require("better_escape").setup({
			timeout = 200,
			-- merge escape_keymaps with require("brimalval.core.keymaps")
			mappings = vim.tbl_deep_extend("force", escape_keymaps, require("brimalval.core.keymaps")),
		})
	end,
}
