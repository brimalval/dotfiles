return {
	"ahkohd/difft.nvim",
	keys = {
		{
			"<leader>gd",
			function()
				if Difft.is_visible() then
					Difft.hide()
				else
					Difft.diff()
				end
			end,
			desc = "Toggle Difft",
		},
	},
	config = function()
		require("difft").setup({
			command = "GIT_EXTERNAL_DIFF='difft --color=always' git diff",
			layout = "float",
			diff = {
				highlights = {
					add = { fg = "#302E4B", bg = "#3E8FB0" },
					delete = { fg = "#302E4B", bg = "#EB6F92" },
				},
			},
		})
	end,
}
