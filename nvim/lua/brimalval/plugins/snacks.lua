return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		bigfile = { enabled = true },
		dashboard = {
			enabled = true,
			sections = {
				{
					section = "terminal",
					cmd = "chafa "
						.. vim.fn.stdpath("config")
						.. "/nyancattransparent.png --format symbols --symbols vhalf --size 60x17 --stretch; sleep .1",
					height = 17,
					padding = 1,
				},
				{
					pane = 2,
					{ section = "keys", gap = 1, padding = 1 },
					{ section = "startup" },
				},
			},
		},
		explorer = { enabled = true },
		image = { enabled = true },
		indent = { enabled = true },
		input = { enabled = true },
		notifier = {
			enabled = true,
			timeout = 3000,
		},
		-- available layouts: bottom, default, dropdown, ivy, ivy_split, left,
		-- right, select, sidebar, telescope, top, vertical, vscode
		picker = {
			enabled = true,
			layout = "dropdown",
			previewers = {
				diff = {
					builtin = true,
					cmd = { "delta" },
				},
			},
		},
		quickfile = { enabled = true },
		scope = { enabled = true },
		scratch = {
			enabled = true,
			win_by_ft = {
				python = {
					keys = {
						["source"] = {
							"<cr>",
							function(self)
								local name = "scratch." .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(self.buf), ":e")
								run_scratch_code("python", { buf = self.buf, name = name })
							end,
							desc = "Source buffer",
							mode = { "n", "x" },
						},
					},
				},
				typescript = {
					keys = {
						["source"] = {
							"<cr>",
							function(self)
								local name = "scratch." .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(self.buf), ":e")
								run_scratch_code("typescript", { buf = self.buf, name = name })
							end,
							desc = "Source buffer",
							mode = { "n", "x" },
						},
					},
				},
			},
		},
		scroll = { enabled = false, animate = {
			duration = { step = 20, total = 100 },
		} },
		statuscolumn = { enabled = true },
		words = { enabled = true },
		styles = {
			notification = {
				-- wo = { wrap = true } -- Wrap notifications
			},
		},
	},
	keys = {
		-- Top Pickers & Explorer
		{
			"<leader><space>",
			function()
				Snacks.picker.smart()
			end,
			desc = "Smart Find Files",
		},
		{
			"<leader>,",
			function()
				Snacks.picker.buffers()
			end,
			desc = "Buffers",
		},
		{
			"<leader>/",
			function()
				Snacks.picker.lines({})
			end,
			desc = "Search current buffer",
		},
		{
			"<leader>:",
			function()
				Snacks.picker.command_history()
			end,
			desc = "Command History",
		},
		{
			"<leader>n",
			function()
				Snacks.picker.notifications()
			end,
			desc = "Notification History",
		},
		{
			"<leader>e",
			function()
				Snacks.explorer()
			end,
			desc = "File Explorer",
		},
		-- find
		{
			"<leader>fb",
			function()
				Snacks.picker.buffers()
			end,
			desc = "Buffers",
		},
		{
			"<leader>fc",
			function()
				Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
			end,
			desc = "Find Config File",
		},
		{
			"<leader>ff",
			function()
				Snacks.picker.files()
			end,
			desc = "Find Files",
		},
		{
			"<leader>fF",
			function()
				Snacks.picker.files({
					hidden = true,
				})
			end,
			desc = "Find Files (Including Hidden)",
		},
		{
			"<leader>fg",
			function()
				Snacks.picker.git_files()
			end,
			desc = "Find Git Files",
		},
		{
			"<leader>fp",
			function()
				Snacks.picker.projects()
			end,
			desc = "Projects",
		},
		{
			"<leader>fr",
			function()
				Snacks.picker.recent()
			end,
			desc = "Recent",
		},
		-- git
		{
			"<leader>gb",
			function()
				Snacks.picker.git_branches()
			end,
			desc = "Git Branches",
		},
		{
			"<leader>gl",
			function()
				Snacks.picker.git_log()
			end,
			desc = "Git Log",
		},
		{
			"<leader>gL",
			function()
				Snacks.picker.git_log_line()
			end,
			desc = "Git Log Line",
		},
		{
			"<leader>gs",
			function()
				Snacks.picker.git_status()
			end,
			desc = "Git Status",
		},
		{
			"<leader>gS",
			function()
				Snacks.picker.git_stash()
			end,
			desc = "Git Stash",
		},
		-- {
		-- 	"<leader>gd",
		-- 	function()
		-- 		Snacks.picker.git_diff()
		-- 	end,
		-- 	desc = "Git Diff (Hunks)",
		-- },
		{
			"<leader>gf",
			function()
				Snacks.picker.git_log_file()
			end,
			desc = "Git Log File",
		},
		-- Grep
		{
			"<leader>sb",
			function()
				Snacks.picker.lines()
			end,
			desc = "Buffer Lines",
		},
		{
			"<leader>sB",
			function()
				Snacks.picker.grep_buffers()
			end,
			desc = "Grep Open Buffers",
		},
		{
			"<leader>sg",
			function()
				Snacks.picker.grep()
			end,
			desc = "Grep",
		},
		{
			"<leader>sG",
			function()
				Snacks.picker.grep({ hidden = true })
			end,
			desc = "Grep all",
		},
		{
			"<leader>sw",
			function()
				Snacks.picker.grep_word()
			end,
			desc = "Visual selection or word",
			mode = { "n", "x" },
		},
		-- search
		{
			'<leader>s"',
			function()
				Snacks.picker.registers({
					actions = {
						edit = function(_, item)
							-- TODO: figure out how to programmatically quit and/or refresh the picker
							vim.ui.input({
								prompt = "Enter new value for [" .. item.reg .. "] register: ",
								default = item.value,
							}, function(input)
								vim.fn.setreg(item.reg, input)
							end)
						end,
					},
					win = {
						input = {
							keys = {
								["e"] = {
									"edit",
									mode = "n",
								},
							},
						},
					},
				})
			end,
			desc = "Registers",
		},
		{
			"<leader>s/",
			function()
				Snacks.picker.search_history()
			end,
			desc = "Search History",
		},
		{
			"<leader>sa",
			function()
				Snacks.picker.autocmds()
			end,
			desc = "Autocmds",
		},
		{
			"<leader>sb",
			function()
				Snacks.picker.lines()
			end,
			desc = "Buffer Lines",
		},
		{
			"<leader>sc",
			function()
				Snacks.picker.command_history()
			end,
			desc = "Command History",
		},
		{
			"<leader>sC",
			function()
				Snacks.picker.commands()
			end,
			desc = "Commands",
		},
		{
			"<leader>sd",
			function()
				Snacks.picker.diagnostics()
			end,
			desc = "Diagnostics",
		},
		{
			"<leader>sD",
			function()
				Snacks.picker.diagnostics_buffer()
			end,
			desc = "Buffer Diagnostics",
		},
		{
			"<leader>sh",
			function()
				Snacks.picker.help()
			end,
			desc = "Help Pages",
		},
		{
			"<leader>sH",
			function()
				Snacks.picker.highlights()
			end,
			desc = "Highlights",
		},
		{
			"<leader>si",
			function()
				Snacks.picker.icons()
			end,
			desc = "Icons",
		},
		{
			"<leader>sj",
			function()
				Snacks.picker.jumps()
			end,
			desc = "Jumps",
		},
		{
			"<leader>sk",
			function()
				Snacks.picker.keymaps()
			end,
			desc = "Keymaps",
		},
		{
			"<leader>sl",
			function()
				Snacks.picker.loclist()
			end,
			desc = "Location List",
		},
		{
			"<leader>sm",
			function()
				Snacks.picker.marks()
			end,
			desc = "Marks",
		},
		{
			"<leader>sM",
			function()
				Snacks.picker.man()
			end,
			desc = "Man Pages",
		},
		{
			"<leader>sp",
			function()
				Snacks.picker.lazy()
			end,
			desc = "Search for Plugin Spec",
		},
		{
			"<leader>sq",
			function()
				Snacks.picker.qflist()
			end,
			desc = "Quickfix List",
		},
		{
			"<leader>sR",
			function()
				Snacks.picker.resume()
			end,
			desc = "Resume",
		},
		{
			"<leader>su",
			function()
				Snacks.picker.undo()
			end,
			desc = "Undo History",
		},
		{
			"<leader>uC",
			function()
				Snacks.picker.colorschemes()
			end,
			desc = "Colorschemes",
		},
		-- LSP
		{
			"gd",
			function()
				Snacks.picker.lsp_definitions()
			end,
			desc = "Goto Definition",
		},
		{
			"gD",
			function()
				Snacks.picker.lsp_declarations()
			end,
			desc = "Goto Declaration",
		},
		{
			"gr",
			function()
				Snacks.picker.lsp_references()
			end,
			nowait = true,
			desc = "References",
		},
		{
			"gI",
			function()
				Snacks.picker.lsp_implementations()
			end,
			desc = "Goto Implementation",
		},
		{
			"gy",
			function()
				Snacks.picker.lsp_type_definitions()
			end,
			desc = "Goto T[y]pe Definition",
		},
		{
			"<leader>ss",
			function()
				Snacks.picker.lsp_symbols()
			end,
			desc = "LSP Symbols",
		},
		{
			"<leader>st",
			function()
				Snacks.picker.todo_comments()
			end,
			desc = "Todo Comments",
		},
		{
			"<leader>sS",
			function()
				Snacks.picker.lsp_workspace_symbols()
			end,
			desc = "LSP Workspace Symbols",
		},
		-- Other
		{
			"<leader>z",
			function()
				Snacks.zen()
			end,
			desc = "Toggle Zen Mode",
		},
		{
			"<leader>Z",
			function()
				Snacks.zen.zoom()
			end,
			desc = "Toggle Zoom",
		},
		{
			"<leader>.",
			function()
				Snacks.scratch()
			end,
			desc = "Toggle Scratch Buffer",
		},
		{
			"<leader>S",
			function()
				Snacks.scratch.select()
			end,
			desc = "Select Scratch Buffer",
		},
		{
			"<leader>n",
			function()
				Snacks.notifier.show_history()
			end,
			desc = "Notification History",
		},
		{
			"<leader>bd",
			function()
				Snacks.bufdelete()
			end,
			desc = "Delete Buffer",
		},
		{
			"<leader>bD",
			function()
				Snacks.bufdelete.all()
			end,
			desc = "Delete All Buffers",
		},
		{
			"<leader>cR",
			function()
				Snacks.rename.rename_file()
			end,
			desc = "Rename File",
		},
		{
			"<leader>gB",
			function()
				Snacks.gitbrowse()
			end,
			desc = "Git Browse",
			mode = { "n", "v" },
		},
		{
			"<leader>gg",
			function()
				Snacks.lazygit()
			end,
			desc = "Lazygit",
		},
		{
			"<leader>un",
			function()
				Snacks.notifier.hide()
			end,
			desc = "Dismiss All Notifications",
		},
		{
			"<c-/>",
			function()
				Snacks.terminal()
			end,
			desc = "Toggle Terminal",
		},
		{
			"<c-_>",
			function()
				Snacks.terminal()
			end,
			desc = "which_key_ignore",
		},
		{
			"]]",
			function()
				Snacks.words.jump(vim.v.count1)
			end,
			desc = "Next Reference",
			mode = { "n", "t" },
		},
		{
			"[[",
			function()
				Snacks.words.jump(-vim.v.count1)
			end,
			desc = "Prev Reference",
			mode = { "n", "t" },
		},
		{
			"<leader>N",
			desc = "Neovim News",
			function()
				Snacks.win({
					file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
					width = 0.6,
					height = 0.6,
					wo = {
						spell = false,
						wrap = false,
						signcolumn = "yes",
						statuscolumn = " ",
						conceallevel = 3,
					},
				})
			end,
		},
		{
			"<leader>bo",
			function()
				Snacks.bufdelete({
					filter = function(buf)
						return #vim.fn.win_findbuf(buf) == 0
					end,
				})
				vim.notify("Deleted all hidden buffers")
			end,
			desc = "Delete all hidden buffers",
		},
	},
	init = function()
		--------- Python running script by linusboehm ---------
		local defaults = {
			name = "Output",
			ft = vim.bo.filetype,
			---@type string|string[]?
			icon = nil, -- `icon|{icon, icon_hl}`. defaults to the filetype icon
			win = { style = "output" },
		}

		local height = 20

		--- Show lines in a floating buffer at the bottom.
		---@param lines string
		---@param opts? snacks.scratch.Config
		local function show_output(lines, opts)
			Snacks.config.style("output", {
				width = 0,
				height = height,
				backdrop = false,
				row = vim.api.nvim_get_option_value("lines", {}) - height,
				bo = { buftype = "nofile", buflisted = false, bufhidden = "delete", swapfile = false, undofile = false },
				border = "single",
				minimal = false,
				noautocmd = false,
				zindex = 100,
				ft = "output",
				wo = { winhighlight = "NormalFloat:Normal", colorcolumn = "" },
			})
			opts = Snacks.config.get("output", defaults, opts)
			opts.win = Snacks.win.resolve("output", opts.win, { show = false })

			local out_buf = vim.api.nvim_create_buf(false, true)

			local content = {}
			for line in lines:gmatch("([^\n]*)\n?") do
				table.insert(content, line)
			end
			-- Remove trailing empty lines
			for i = #content, 1, -1 do
				if content[i] == "" then
					table.remove(content, i)
				else
					break
				end
			end
			vim.api.nvim_buf_set_lines(out_buf, 0, -1, false, content)
			opts.win.buf = out_buf
			local win = Snacks.win(opts.win)
			win:set_title("Scratch Output")
			return win:show()
		end

		--- Run the current buffer or a range of lines.
		--- Shows the output in a scratch buffer at the bottom.
		---@param opts? {name?:string, buf?:number, print?:boolean}
		function run_scratch_code(ft, opts)
			local ns = vim.api.nvim_create_namespace("snacks_debug")
			opts = vim.tbl_extend("force", { print = true }, opts or {})
			local buf = opts.buf or 0
			buf = buf == 0 and vim.api.nvim_get_current_buf() or buf
			local name = opts.name or vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")

			-- Get the lines to run
			local lines ---@type string[]
			local mode = vim.fn.mode()
			if mode:find("[vV]") then
				if mode == "v" then
					vim.cmd("normal! v")
				elseif mode == "V" then
					vim.cmd("normal! V")
				end
				local from = vim.api.nvim_buf_get_mark(buf, "<")
				local to = vim.api.nvim_buf_get_mark(buf, ">")

				-- for some reason, sometimes the column is off by one
				-- see: https://github.com/folke/snacks.nvim/issues/190
				local col_to = math.min(to[2] + 1, #vim.api.nvim_buf_get_lines(buf, to[1] - 1, to[1], false)[1])

				lines = vim.api.nvim_buf_get_text(buf, from[1] - 1, from[2], to[1] - 1, col_to, {})
				-- Insert empty lines to keep the line numbers
				for _ = 1, from[1] - 1 do
					table.insert(lines, 1, "")
				end
				vim.fn.feedkeys("gv", "nx")
			else
				lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
			end

			-- Clear diagnostics and extmarks
			local function reset()
				vim.diagnostic.reset(ns, buf)
				vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
			end
			reset()
			vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
				group = vim.api.nvim_create_augroup("snacks_debug_run_" .. buf, { clear = true }),
				buffer = buf,
				callback = reset,
			})

			local exec_command_by_ft = {
				["python"] = "python",
				["typescript"] = "node",
			}
			-- Transpile first
			local command = "echo " .. vim.fn.shellescape(table.concat(lines, "\n")) .. " | "
			if ft == "typescript" then
				command = command .. " esbuild --loader=ts --platform=node | "
			end
			command = command .. exec_command_by_ft[ft] .. " 2>&1"
			local handle = io.popen(command)
			if not handle then
				Snacks.notify.error("Didn't get popen handle.", { title = name })
				return
			end
			local out = handle:read("*a")
			handle:close()

			if out == "" then
				Snacks.notify.info("No output.", { title = name, ft = ft })
			else
				show_output(out)
			end
		end
		------------------------------------------------------------------------------
		vim.api.nvim_create_autocmd("User", {
			pattern = "VeryLazy",
			callback = function()
				-- Setup some globals for debugging (lazy-loaded)
				_G.dd = function(...)
					Snacks.debug.inspect(...)
				end
				_G.bt = function()
					Snacks.debug.backtrace()
				end
				vim.print = _G.dd -- Override print to use snacks for `:=` command

				-- Create some toggle mappings
				Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
				Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
				Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
				Snacks.toggle.diagnostics():map("<leader>ud")
				Snacks.toggle.line_number():map("<leader>ul")
				Snacks.toggle
					.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
					:map("<leader>uc")
				Snacks.toggle.treesitter():map("<leader>uT")
				Snacks.toggle
					.option("background", { off = "light", on = "dark", name = "Dark Background" })
					:map("<leader>ub")
				Snacks.toggle({
					name = "Virtual Lines",
					get = function()
						return vim.diagnostic.config().virtual_lines ~= false
					end,
					set = function(state)
						vim.diagnostic.config({
							virtual_lines = state and {
								current_line = true,
							} or false,
						})
					end,
				}):map("<leader>uv")
				Snacks.toggle.inlay_hints():map("<leader>uh")
				Snacks.toggle.indent():map("<leader>ug")
				Snacks.toggle.dim():map("<leader>uD")
			end,
		})
	end,
}
