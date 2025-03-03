return {
	"tpope/vim-dadbod",
	{
		"kristijanhusak/vim-dadbod-ui",
		dependencies = {
			"tpope/vim-dadbod",
			{
				"kristijanhusak/vim-dadbod-completion",
				ft = { "sql", "mysql" },
			},
		},
		init = function()
			vim.g.db_ui_execute_on_save = 0
		end,
	},
}
