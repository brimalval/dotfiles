return {
	"nvim-mini/mini.surround",
	version = "*",
	config = function()
		require("mini.surround").setup({
			mappings = {
				add = "gs",
				find = "fs",
				find_left = "fS",
				replace = "cs",
				delete = "ds",
				-- clear these bindings; they're not needed and they mess with
				-- flash.nvim
				update_n_lines = "",
				highlight = "",
			},
		})
	end,
}
