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
		config = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "sql", "mysql", "plsql" },
				callback = function()
					vim.keymap.set("n", "<leader>S", function()
						vim.cmd("normal! vap")
						vim.api.nvim_feedkeys(
							vim.api.nvim_replace_termcodes("<Plug>(DBUI_ExecuteQuery)", true, false, true),
							"n",
							false
						)
					end, { buffer = true, desc = "Execute current block" })
				end,
			})
		end,
	},
}
