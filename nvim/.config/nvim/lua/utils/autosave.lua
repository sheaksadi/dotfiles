local M = {}

-- Default configuration
local config = {
	timeout = 15000, -- 15 seconds in milliseconds
	enabled = true,
	events = { "TextChanged", "TextChangedI", "InsertLeave" },
	save_on_focus_lost = true,
	exclude_filetypes = { "help", "alpha", "dashboard", "NvimTree", "Trouble", "lazy" },
	exclude_buftypes = { "nofile", "prompt", "popup" },
	only_save_existing_files = true, -- Only save files that already exist on disk
	notify = true, -- Show notification when auto-saving
	keybind = "<leader>as", -- Keybind for toggle (set to false to disable)
	debounce_delay = 1000, -- Debounce delay in milliseconds (1 second)
}

-- Timer storage for each buffer
local timers = {}

-- Debounce tracking: stores last event time for each buffer
local last_event_time = {}

-- Check if buffer should be auto-saved
local function should_autosave(bufnr)
	if not config.enabled then
		return false
	end

	-- Check if buffer is valid and loaded
	if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
		return false
	end

	-- Check if buffer is modified
	if not vim.bo[bufnr].modified then
		return false
	end

	-- Check if buffer is modifiable
	if not vim.bo[bufnr].modifiable then
		return false
	end

	-- Check buffer type
	local buftype = vim.bo[bufnr].buftype
	if vim.tbl_contains(config.exclude_buftypes, buftype) then
		return false
	end

	-- Check file type
	local filetype = vim.bo[bufnr].filetype
	if vim.tbl_contains(config.exclude_filetypes, filetype) then
		return false
	end

	-- Check if file exists (if only_save_existing_files is true)
	if config.only_save_existing_files then
		local filename = vim.api.nvim_buf_get_name(bufnr)
		if filename == "" or not vim.fn.filereadable(filename) == 1 then
			return false
		end
	end

	return true
end

-- Auto-save a buffer
local function autosave_buffer(bufnr)
	if not should_autosave(bufnr) then
		return
	end

	local success, err = pcall(function()
		vim.api.nvim_buf_call(bufnr, function()
			vim.cmd("silent! write")
		end)
	end)

	if success then
		if config.notify then
			local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
			vim.notify("Auto-saved: " .. (filename ~= "" and filename or "buffer"), vim.log.levels.INFO)
		end
	else
		if config.notify then
			vim.notify("Auto-save failed: " .. tostring(err), vim.log.levels.WARN)
		end
	end
end

-- Start or restart timer for a buffer
local function start_timer(bufnr)
	-- Clear existing timer if it exists
	if timers[bufnr] then
		timers[bufnr]:stop()
		timers[bufnr]:close()
	end

	-- Create new timer
	timers[bufnr] = vim.loop.new_timer()
	timers[bufnr]:start(
		config.timeout,
		0,
		vim.schedule_wrap(function()
			autosave_buffer(bufnr)
			-- Clean up timer
			if timers[bufnr] then
				timers[bufnr]:close()
				timers[bufnr] = nil
			end
		end)
	)
end

-- Stop timer for a buffer
local function stop_timer(bufnr)
	if timers[bufnr] then
		timers[bufnr]:stop()
		timers[bufnr]:close()
		timers[bufnr] = nil
	end
end

-- Handle buffer activity
local function on_buffer_activity()
	local bufnr = vim.api.nvim_get_current_buf()

	if not should_autosave(bufnr) then
		stop_timer(bufnr)
		return
	end

	-- Debounce check
	local current_time = vim.loop.hrtime() / 1000000 -- Convert to milliseconds
	local last_time = last_event_time[bufnr] or 0

	if current_time - last_time < config.debounce_delay then
		-- Too soon since last event, skip this one
		return
	end

	-- Update last event time and start/restart timer
	last_event_time[bufnr] = current_time
	start_timer(bufnr)
end

-- Clean up timers for deleted buffers
local function cleanup_timers()
	for bufnr, timer in pairs(timers) do
		if not vim.api.nvim_buf_is_valid(bufnr) then
			timer:stop()
			timer:close()
			timers[bufnr] = nil
			last_event_time[bufnr] = nil -- Clean up debounce tracking too
		end
	end
end

-- Setup autocommands
local function setup_autocmds()
	local group = vim.api.nvim_create_augroup("AutoSave", { clear = true })

	-- Handle buffer activity events
	vim.api.nvim_create_autocmd(config.events, {
		group = group,
		callback = on_buffer_activity,
	})

	-- Handle focus lost if enabled
	if config.save_on_focus_lost then
		vim.api.nvim_create_autocmd("FocusLost", {
			group = group,
			callback = function()
				-- Save all modified buffers
				for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
					if should_autosave(bufnr) then
						autosave_buffer(bufnr)
						stop_timer(bufnr) -- Stop timer since we just saved
					end
				end
			end,
		})
	end

	-- Clean up timers when buffers are deleted
	vim.api.nvim_create_autocmd("BufDelete", {
		group = group,
		callback = function(args)
			stop_timer(args.buf)
			last_event_time[args.buf] = nil -- Clean up debounce tracking
		end,
	})
	-- Stop timer on manual save
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = group,
		callback = function(args)
			-- Only act on the buffer that was just saved
			if args.buf == vim.api.nvim_get_current_buf() then
				stop_timer(args.buf)
				last_event_time[args.buf] = nil -- Clean up debounce tracking
			end
		end,
	})
	-- Periodic cleanup
	vim.api.nvim_create_autocmd("VimResized", {
		group = group,
		callback = cleanup_timers,
	})
end

-- Plugin setup function
M.setup = function(opts)
	-- Merge user config with defaults
	if opts then
		config = vim.tbl_deep_extend("force", config, opts)
	end

	-- Validate timeout
	if config.timeout < 1000 then
		vim.notify("AutoSave: timeout must be at least 1000ms (1 second)", vim.log.levels.WARN)
		config.timeout = 1000
	end

	-- Setup autocommands
	setup_autocmds()

	-- Setup keybind if configured
	if config.keybind and config.keybind ~= false then
		vim.keymap.set("n", config.keybind, function()
			vim.cmd("AutoSaveToggle")
		end, { desc = "Toggle AutoSave", noremap = true, silent = true })
	end

	-- Create user commands
	vim.api.nvim_create_user_command("AutoSaveToggle", function()
		config.enabled = not config.enabled
		if config.enabled then
			vim.notify("AutoSave enabled", vim.log.levels.INFO)
		else
			vim.notify("AutoSave disabled", vim.log.levels.INFO)
			-- Clear all timers and debounce tracking
			for bufnr, timer in pairs(timers) do
				timer:stop()
				timer:close()
				timers[bufnr] = nil
				last_event_time[bufnr] = nil
			end
		end
	end, { desc = "Toggle auto-save functionality" })

	vim.api.nvim_create_user_command("AutoSaveNow", function()
		local bufnr = vim.api.nvim_get_current_buf()
		if should_autosave(bufnr) then
			autosave_buffer(bufnr)
			stop_timer(bufnr) -- Reset timer
			start_timer(bufnr)
		else
			vim.notify("Current buffer cannot be auto-saved", vim.log.levels.WARN)
		end
	end, { desc = "Save current buffer now and reset timer" })

	vim.api.nvim_create_user_command("AutoSaveStatus", function()
		print("AutoSave Status:")
		print("  Enabled: " .. tostring(config.enabled))
		print("  Timeout: " .. config.timeout .. "ms")
		print("  Debounce delay: " .. config.debounce_delay .. "ms")
		print("  Active timers: " .. vim.tbl_count(timers))
		for bufnr, _ in pairs(timers) do
			local name = vim.api.nvim_buf_get_name(bufnr)
			local filename = name ~= "" and vim.fn.fnamemodify(name, ":t") or "unnamed buffer"
			print("    Buffer " .. bufnr .. ": " .. filename)
		end
	end, { desc = "Show auto-save status" })
end

-- Public API
M.toggle = function()
	vim.cmd("AutoSaveToggle")
end

M.save_now = function()
	vim.cmd("AutoSaveNow")
end

M.is_enabled = function()
	return config.enabled
end

M.get_config = function()
	return vim.deepcopy(config)
end

return M
