local has_telescope, telescope = pcall(require, 'telescope')

if not has_telescope then
	error('This plugins requires nvim-telescope/telescope.nvim')
end

local actions = require("telescope.actions")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local builtin = require("telescope.builtin")
local project_dirs_file = vim.fn.stdpath('data') .. '/telescope-projects.lua'

local select_project = function(opts, projects, run_task_on_selected_project)
	pickers.new(opts, {
		prompt_title = 'Select a project',
		results_title = 'Projects',
		finder = finders.new_table {results = projects},
		sorter = conf.file_sorter(opts),
		attach_mappings = function(prompt_bufnr)
			local on_project_selected = function()
				local selection = actions.get_selected_entry(prompt_bufnr)
				actions.close(prompt_bufnr)
				run_task_on_selected_project(selection.value)
			end
			actions.goto_file_selection_edit:replace(on_project_selected)
			return true
		end
	}):find()
end

local project = function(opts)
	opts = opts or {}

	-- TODO figure this out:

	-- local project_dirs = {}
	-- for line in io.lines(project_dirs_file) do
	-- 	table.insert(project_dirs, line)
	-- end

	local project_dirs = {["nvim config"] = "~/.config/nvim"}
	local projects = {}

	local search_selected_project = function(selection)
		local selected_directory = project_dirs[selection]
		builtin.find_files({cwd = selected_directory})
	end

	-- TODO allow a way to choose between the above function and this one.
	local open_path_at_selected_project = function(selection)
		vim.api.nvim_command('Explore ' .. project_dirs[selection])
	end

	for k in pairs(project_dirs) do
		table.insert(projects, k)
	end

	select_project(opts, projects, search_selected_project)
end

return telescope.register_extension {exports = {project = project}}
