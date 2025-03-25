local function is_diffview_open()
	return require("diffview.lib").get_current_view() ~= nil
end

local function do_git_diff(from_branch)
	local git_branches = vim.fn.system("git branch --all --format='%(refname:short)'")
	git_branches = string.gsub(git_branches, "origin/", "")
	local git_branches_list = vim.split(git_branches, "\n")
	git_branches_list = vim.fn.uniq(git_branches_list)
	local unique_branches = {}
	for _, branch in ipairs(git_branches_list) do
		if not vim.tbl_contains(unique_branches, branch) and branch ~= "" then
			table.insert(unique_branches, branch)
		end
	end
	-- Add "current branch" as the first option
	table.insert(unique_branches, 1, "Current branch")
	vim.ui.select(unique_branches, {
		prompt = from_branch and "Select branch to compare against:" or "Select target branch:",
	}, function(branch)
		if not branch then
			return
		end
		if not from_branch then
			vim.ui.select(unique_branches, {
				prompt = "Select branch to compare against:",
			}, function(to_branch)
				if not to_branch then
					return
				end
				vim.notify("DiffviewOpen " .. branch .. "..." .. to_branch)
				vim.cmd("DiffviewOpen " .. branch .. "..." .. to_branch)
			end)
		else
			if branch == "Current branch" then
				vim.cmd("DiffviewOpen " .. from_branch)
			else
				vim.cmd("DiffviewOpen " .. branch)
			end
		end
	end)
end

return {
	"sindrets/diffview.nvim",
	dependencies = {
		-- For the Snacks toggle
		"folke/snacks.nvim",
	},
	event = "VeryLazy",
	config = function()
		require("diffview").setup()
		Snacks.toggle({
			name = "Diffview",
			notify = false,
			wk_desc = {
				disabled = "Open (against current branch) ",
			},
			get = is_diffview_open,
			set = function(state)
				if state == true then
					local current_branch = vim.fn.system("git branch --show-current --format='%(refname:short)'")
					do_git_diff(current_branch)
				else
					vim.cmd("DiffviewClose")
				end
			end,
		}):map("<leader>gd")

		Snacks.toggle({
			name = "Diffview",
			notify = false,
			wk_desc = {
				disabled = "Open (select 2 target branches) ",
			},
			get = is_diffview_open,
			set = function(state)
				if state == true then
					do_git_diff()
				else
					vim.cmd("DiffviewClose")
				end
			end,
		}):map("<leader>gD")

		Snacks.toggle({
			name = "Diffview",
			notify = false,
			wk_desc = {
				disabled = "Current file history ",
			},
			get = is_diffview_open,
			set = function(state)
				if state == true then
					vim.cmd("DiffviewFileHistory %")
				else
					vim.cmd("DiffviewClose")
				end
			end,
		}):map("<leader>gf")

		Snacks.toggle({
			name = "Diffview",
			notify = false,
			wk_desc = {
				disabled = "File history ",
			},
			get = is_diffview_open,
			set = function(state)
				if state == true then
					vim.cmd("DiffviewFileHistory")
				else
					vim.cmd("DiffviewClose")
				end
			end,
		}):map("<leader>gF")
	end,
}
