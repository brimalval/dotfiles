return {
	{
		"Bekaboo/dropbar.nvim",
		-- optional, but required for fuzzy finder support
		dependencies = {
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
		},
		config = function()
			local function jump_without_expanding()
				local utils = require("dropbar.utils")
				local menu = utils.menu.get_current()
				if not menu then
					return
				end
				local cursor = vim.api.nvim_win_get_cursor(menu.win)
				local entry = menu.entries[cursor[1]]
				local component = entry:first_clickable(entry.padding.left + entry.components[1]:bytewidth())
				if component then
					menu:click_on(component, nil, 1, "l")
				end
			end
			vim.cmd([[hi WinBarNC guibg=false]])
			vim.cmd([[hi WinBar guibg=false]])
			local dropbar_api = require("dropbar.api")
			vim.keymap.set("n", "<Leader>;", dropbar_api.pick, { desc = "Pick symbols in winbar" })
			vim.keymap.set("n", "[\\", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
			vim.keymap.set("n", "]\\", dropbar_api.select_next_context, { desc = "Select next context" })
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
				menu = {
					keymaps = {
						-- close menu
						["o"] = jump_without_expanding,
						["<CR>"] = jump_without_expanding,
						["h"] = "<C-w>q",
						["l"] = function()
							local utils = require("dropbar.utils")
							local menu = utils.menu.get_current()
							if not menu then
								return
							end
							local cursor = vim.api.nvim_win_get_cursor(menu.win)
							local component = menu.entries[cursor[1]]:first_clickable(cursor[2])
							if component then
								menu:click_on(component, nil, 1, "l")
							end
						end,
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
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = "VeryLazy",
		opts = function()
			local tsc = require("treesitter-context")
			Snacks.toggle({
				name = "Treesitter Context",
				get = tsc.enabled,
				set = function(state)
					if state then
						tsc.enable()
					else
						tsc.disable()
					end
				end,
			}):map("<leader>ut")
			vim.keymap.set("n", "[c", function()
				require("treesitter-context").go_to_context(vim.v.count1)
			end, { silent = true })
			return { mode = "cursor", max_lines = 3 }
		end,
	},
	-- File explorer
	---@type LazySpec
	{
		"mikavilpas/yazi.nvim",
		version = "*", -- use the latest stable version
		event = "VeryLazy",
		dependencies = {
			{ "nvim-lua/plenary.nvim", lazy = true },
			{ "folke/snacks.nvim" },
		},
		keys = {
			-- 👇 in this section, choose your own keymappings!
			{
				"<leader>e",
				mode = { "n", "v" },
				"<cmd>Yazi<cr>",
				desc = "Open yazi at the current file",
			},
			{
				-- Open in the current working directory
				"<leader>E",
				"<cmd>Yazi cwd<cr>",
				desc = "Open the file manager in nvim's working directory",
			},
			{
				"<leader>-",
				"<cmd>Yazi toggle<cr>",
				desc = "Resume the last yazi session",
			},
		},
		---@type YaziConfig | {}
		opts = {
			-- if you want to open yazi instead of netrw, see below for more info
			open_for_directories = true,
			keymaps = {
				show_help = "<f1>",
			},
			integrations = {
				grep_in_directory = function(directory)
					Snacks.picker.grep({ cwd = directory })
				end,
				grep_in_selected_files = function(selected_files)
					Snacks.picker.grep({ paths = selected_files })
				end,
			},
		},
		-- 👇 if you use `open_for_directories=true`, this is recommended
		init = function()
			-- mark netrw as loaded so it's not loaded at all.
			--
			-- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
			vim.g.loaded_netrwPlugin = 1
		end,
	},
}
