local M = {}

-- Define paths to watch and their corresponding remote destinations
M.paths = {
	["/mnt/c/users/sheaksadi/WebstormProjects/pubg_leaderboard/"] = "sheaksadi@deadhorse.net:~/pubg_test/pubg_leaderboard/",
	["/mnt/c/users/sheaksadi/WebstormProjects/pubg_scoreboard/"] = "sheaksadi@deadhorse.net:~/pubg_test/pubg_scoreboard/",
	["/mnt/c/users/sheaksadi/WebstormProjects/jobot/"] = "sheaksadi@deadhorse.net:~/jobot/",
	["/mnt/c/users/sheaksadi/GolandProjects/mm-backend/"] = "sheaksadi@deadhorse.net:~/mm-backend/",
}

-- Define excluded folders
M.excluded_folders = {
	"node_modules",
	"dist",
	".nuxt",
	".git",
	"logs",
	"*.log",
}

-- Function to show notifications using vim.notify
local function notify(message, level)
	level = level or "info"
	vim.notify(message, vim.log.levels[level:upper()])
end

-- Function to check if a file should be excluded
local function should_exclude(filepath)
	for _, exclude in ipairs(M.excluded_folders) do
		if filepath:find(exclude) then
			return true
		end
	end
	return false
end

-- Function to run a shell command in the background
local function run_command_async(cmd, on_exit)
	local job_id = vim.fn.jobstart(cmd, {
		on_stdout = function(_, data)
			if data then
				notify(table.concat(data, "\n"), "info")
			end
		end,
		on_stderr = function(_, data)
			if data then
				-- notify(table.concat(data, "\n"), "error")
			end
		end,
		on_exit = function(_, code)
			if on_exit then
				on_exit(code)
			end
		end,
		stdout_buffered = true,
		stderr_buffered = true,
	})

	if job_id <= 0 then
		notify("Failed to start sync job", "error")
		return false
	else
		return true
	end
end

-- Function to normalize paths (ensure trailing slashes are consistent)
local function normalize_path(path)
	return path:gsub("/+$", "") .. "/"
end
local function path_starts_with(full_path, prefix_path)
	full_path = string.lower(tostring(full_path))
	prefix_path = string.lower(tostring(prefix_path))

	-- Ensure prefix_path ends with a slash for proper directory comparison
	if not prefix_path:endsWith("/") then
		prefix_path = prefix_path .. "/"
	end

	-- Check if full_path starts with prefix_path
	return full_path:sub(1, #prefix_path) == prefix_path
end

-- Helper function (or use string.sub directly)
function string.endsWith(str, suffix)
	return str:sub(-#suffix) == suffix
end
-- Function to sync a file or directory with rsync
local function sync_file(filepath)
	-- Check if the file should be excluded
	if should_exclude(filepath) then
		notify("Excluded: " .. filepath, "info")
		return
	end

	-- Loop through the paths and perform sync
	local found_match = false
	for local_path, remote_path in pairs(M.paths) do
		local normalized_local_path = normalize_path(local_path)
		local normalized_filepath = normalize_path(filepath)

		-- Check if the filepath starts with the local_path
		if path_starts_with(normalized_filepath, normalized_local_path) then
			found_match = true

			-- Calculate the relative path
			local relative_path = filepath:sub(#normalized_local_path + 1)
			local remote_full_path = remote_path .. relative_path

			-- Add verbose logging and ignore errors
			local cmd =
				string.format("rsync -avz --progress --stats -v --ignore-errors %s %s", filepath, remote_full_path)
			notify("Starting sync: " .. cmd, "info")

			-- Run rsync in the background
			local success = run_command_async(cmd, function(code)
				if code == 0 then
					notify("Sync completed successfully", "info")
				else
					notify("Sync failed with code: " .. code, "error")
				end
			end)

			if not success then
				notify("Failed to start sync job", "error")
			end

			return
		end
	end

	if not found_match then
		notify("No matching path found for: " .. filepath, "warn")
	end
end

-- Function to sync the entire directory
local function sync_directory()
	local current_dir = vim.fn.expand("%:p")
	local normalized_current_dir = normalize_path(current_dir)
	local found_match = false

	-- Loop through the paths and perform sync
	for local_path, remote_path in pairs(M.paths) do
		local normalized_local_path = normalize_path(local_path)

		-- Check if current directory is within one of our watched paths
		if path_starts_with(normalized_current_dir, normalized_local_path) then
			found_match = true

			-- Build the rsync command with properly quoted exclusions
			local exclude_flags = ""
			for _, exclude in ipairs(M.excluded_folders) do
				exclude_flags = exclude_flags .. string.format(" --exclude='%s'", exclude)
			end

			-- Add verbose logging and ignore errors
			local cmd = string.format(
				"rsync -avz --progress --stats -v --ignore-errors%s %s %s",
				exclude_flags,
				normalized_local_path,
				remote_path
			)
			notify("Starting full directory sync: " .. cmd, "info")

			-- Run rsync in the background
			local success = run_command_async(cmd, function(code)
				if code == 0 then
					notify("Full directory sync completed successfully", "info")
				else
					notify("Full directory sync failed with code: " .. code, "error")
				end
			end)

			if not success then
				notify("Failed to start full directory sync job", "error")
			end
		end
	end

	if not found_match then
		notify("Current directory is not in any sync paths: " .. current_dir, "warn")
	end
end

-- Initialize
function M.setup()
	-- Create commands
	vim.api.nvim_create_user_command("SyncNow", function()
		local filepath = vim.fn.expand("%:p")
		print("filepath:", filepath)
		notify("Manual sync triggered for: " .. filepath, "info")
		sync_file(filepath)
	end, {})

	vim.api.nvim_create_user_command("SyncDir", function()
		notify("Manual sync triggered for current directory", "info")
		sync_directory()
	end, {})

	vim.api.nvim_create_user_command("SyncTest", function()
		notify("test", "info")

		local filepath = vim.fn.expand("%:p")
		print(filepath)
	end, {})
	-- Set keybinds
	vim.api.nvim_set_keymap("n", "<leader>ku", ":SyncNow<CR>", { noremap = true, silent = true })
	vim.api.nvim_set_keymap("n", "<leader>kd", ":SyncDir<CR>", { noremap = true, silent = true })
	vim.api.nvim_set_keymap("n", "<leader>kt", ":SyncTest<CR>", { noremap = true, silent = true })
end

return M
