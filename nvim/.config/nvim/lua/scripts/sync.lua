local M = {}

-- Define paths to watch and their corresponding remote destinations
M.paths = {
  ["/mnt/c/users/sheak.DESKTOP-97UOPK1/WebstormProjects/pubg_leaderboard/"] = "sheaksadi@deadhorse.net:~/pubg_test/pubg_leaderboard/",
  ["/mnt/c/users/sheak.DESKTOP-97UOPK1/WebstormProjects/pubg_scoreboard/"] = "sheaksadi@deadhorse.net:~/pubg_test/pubg_scoreboard/",
  ["/mnt/c/users/sheak.DESKTOP-97UOPK1/WebstormProjects/jobot/"] = "sheaksadi@deadhorse.net:~/jobot/",
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
        notify(table.concat(data, "\n"), "error")
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

-- Function to check SSH connection
function M.check_connection()
  local host = "deadhorse.net"
  local user = "sheaksadi"
  local cmd = string.format("ssh -o BatchMode=yes -o ConnectTimeout=5 %s@%s echo OK", user, host)

  notify("Testing SSH connection to " .. host, "info")
  local success, result = pcall(vim.fn.system, cmd)

  if success and result:find("OK") then
    notify("SSH connection successful", "info")
    return true
  else
    notify("SSH connection failed: " .. (result or "unknown error"), "error")
    return false
  end
end

-- Function to normalize paths (ensure trailing slashes are consistent)
local function normalize_path(path)
  return path:gsub("/+$", "") .. "/"
end

-- Function to sync a file or directory with rsync
local function sync_file(filepath)
  -- Check if the file should be excluded
  if should_exclude(filepath) then
    notify("Excluded: " .. filepath, "info")
    return
  end

  -- Check SSH connection first
  if not M.check_connection() then
    notify("Skipping sync due to SSH connection failure", "error")
    return
  end

  -- Loop through the paths and perform sync
  local found_match = false
  for local_path, remote_path in pairs(M.paths) do
    local normalized_local_path = normalize_path(local_path)
    local normalized_filepath = normalize_path(filepath)

    -- Check if the filepath starts with the local_path
    if normalized_filepath:sub(1, #normalized_local_path) == normalized_local_path then
      found_match = true

      -- Build the rsync command with exclusions
      local exclude_flags = ""
      for _, exclude in ipairs(M.excluded_folders) do
        exclude_flags = exclude_flags .. " --exclude=" .. exclude
      end

      -- Calculate the relative path
      local relative_path = filepath:sub(#normalized_local_path + 1)
      local remote_full_path = remote_path .. relative_path

      -- Add verbose logging and ignore errors
      local cmd = string.format(
        "rsync -avz --progress --stats -v --ignore-errors %s %s %s",
        exclude_flags,
        filepath,
        remote_full_path
      )
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
  -- Check SSH connection first
  if not M.check_connection() then
    notify("Skipping sync due to SSH connection failure", "error")
    return
  end

  -- Loop through the paths and perform sync
  for local_path, remote_path in pairs(M.paths) do
    -- Build the rsync command with exclusions
    local exclude_flags = ""
    for _, exclude in ipairs(M.excluded_folders) do
      exclude_flags = exclude_flags .. " --exclude=" .. exclude
    end

    -- Add verbose logging and ignore errors
    local cmd =
      string.format("rsync -avz --progress --stats -v --ignore-errors %s %s %s", exclude_flags, local_path, remote_path)
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

-- Initialize
function M.setup()
  -- Create commands
  vim.api.nvim_create_user_command("SyncNow", function()
    local filepath = vim.fn.expand("%:p")
    notify("Manual sync triggered for: " .. filepath, "info")
    sync_file(filepath)
  end, {})

  vim.api.nvim_create_user_command("SyncDir", function()
    notify("Manual sync triggered for current directory", "info")
    sync_directory()
  end, {})

  -- Set keybinds
  vim.api.nvim_set_keymap("n", "<leader>su", ":SyncNow<CR>", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("n", "<leader>sd", ":SyncDir<CR>", { noremap = true, silent = true })
end

return M
