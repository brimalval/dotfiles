return {
	"nvimdev/lspsaga.nvim",
	event = "LspAttach",
	config = function()
		local map = vim.keymap.set
		-- Call hierarchy
		map("n", "<Leader>ch", "<Cmd>Lspsaga incoming_calls<CR>", { desc = "Show incoming calls" })
		map("n", "<Leader>cH", "<Cmd>Lspsaga outgoing_calls<CR>", { desc = "Show outgoing calls" })

		-- Overwrite native code actions
		map("n", "<Leader>ca", "<Cmd>Lspsaga code_action<CR>", { desc = "Show code actions" })
		require("lspsaga").setup({
			lightbulb = {
				enable = false,
			},
			-- dropbar.nvim is preferred
			symbol_in_winbar = {
				enable = false,
			},
		})
	end,
	dependencies = {
		"nvim-treesitter/nvim-treesitter", -- optional
		"nvim-tree/nvim-web-devicons", -- optional
	},
}
