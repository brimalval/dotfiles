return {
	{
		"Bekaboo/dropbar.nvim",
		-- optional, but required for fuzzy finder support
		dependencies = {
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
		},
		config = function()
			vim.cmd([[hi WinBarNC guibg=false]])
			vim.cmd([[hi WinBar guibg=false]])
			local dropbar_api = require("dropbar.api")
			vim.keymap.set("n", "<Leader>;", dropbar_api.pick, { desc = "Pick symbols in winbar" })
			vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
			vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Select next context" })
			-- type
			require("dropbar").setup({
				icons = {
					ui = {
						bar = {
							-- chevron
							separator = " ⟢ ",
							background = false,
						},
					},
				},
			})
		end,
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			-- Add border to floating windows
			presets = {
				-- Put input box at the top
				-- command_palette = true,
				long_message_to_split = true,
				lsp_doc_border = true,
			},
			lsp = {
				hover = {
					-- Disable message if hover is not available
					-- ex: shift+k on Typescript code
					silent = true,
				},
			},
			routes = {
				{
					filter = {
						event = "notify",
						kind = "error",
						find = "-32603",
					},
					opts = {
						skip = true,
					},
				},
			},
		},
		keys = {
			{ "<leader>sn", "", desc = "+noice" },
			{
				"<S-Enter>",
				function()
					require("noice").redirect(vim.fn.getcmdline())
				end,
				mode = "c",
				desc = "Redirect Cmdline",
			},
			{
				"<leader>snl",
				function()
					require("noice").cmd("last")
				end,
				desc = "Noice Last Message",
			},
			{
				"<leader>snh",
				function()
					require("noice").cmd("history")
				end,
				desc = "Noice History",
			},
		},
		config = function(_, opts)
			-- HACK: noice shows messages from before it was enabled,
			-- but this is not ideal when Lazy is installing plugins,
			-- so clear the messages in this case.
			if vim.o.filetype == "lazy" then
				vim.cmd([[messages clear]])
			end
			require("noice").setup(opts)
		end,
	},
}
