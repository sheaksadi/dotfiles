-- ~/.config/nvim/lua/utils/M.lua

local M = {} -- Create a module table

-- Helper to get Esc termcode - defined once
local esc = vim.api.nvim_replace_termcodes("<Esc>", true, true, true)

-- Default group name - create once
local default_group_name = "LogMacrosAuGroup"
vim.api.nvim_create_augroup(default_group_name, { clear = true })

--- Sets up a macro in a register to insert a log statement for specified filetypes.
-- Assumes the variable name/text to log has been yanked (e.g., with `yiw`)
-- before invoking the macro (e.g., `@l`).
-- The macro will typically perform: o<prefix><Esc>pa<separator><Esc>pa<suffix><Esc>
-- which means:
--   o         : Open new line below, enter insert mode
--   <prefix>  : Type the prefix string
--   <Esc>p    : Exit insert, paste the yanked text
--   a         : Enter append mode
--   <separator>: Type the separator string
--   <Esc>p    : Exit insert, paste the yanked text again
--   a         : Enter append mode
--   <suffix>  : Type the suffix string
--   <Esc>     : Exit insert mode
--
-- @param config table Configuration table with the following keys:
--   filetypes (table): REQUIRED. List of filetype strings (e.g., {"javascript", "typescript"}).
--   prefix (string): REQUIRED. The text to insert before the first variable name paste (e.g., "console.log('").
--   separator (string): REQUIRED. The text to insert between the two variable name pastes (e.g., ":', ").
--   suffix (string): REQUIRED. The text to insert after the second variable name paste (e.g., ");").
--   register (string): OPTIONAL. The register to store the macro (e.g., "l"). Defaults to "l".
--   group (string): OPTIONAL. The augroup name. Defaults to the module's default group.
function M.setup_log_macro(config)
	-- Basic Input validation
	if not config or type(config) ~= "table" then
		vim.notify("setup_log_macro: Invalid config table provided.", vim.log.levels.ERROR)
		return
	end
	if not config.filetypes or type(config.filetypes) ~= "table" or #config.filetypes == 0 then
		vim.notify("setup_log_macro: 'filetypes' table missing or empty.", vim.log.levels.ERROR)
		return
	end
	if not config.prefix or type(config.prefix) ~= "string" then
		vim.notify("setup_log_macro: 'prefix' string missing.", vim.log.levels.ERROR)
		return
	end
	if not config.separator or type(config.separator) ~= "string" then
		vim.notify("setup_log_macro: 'separator' string missing.", vim.log.levels.ERROR)
		return
	end
	if not config.suffix or type(config.suffix) ~= "string" then
		vim.notify("setup_log_macro: 'suffix' string missing.", vim.log.levels.ERROR)
		return
	end

	local register = config.register or "l"
	local group = config.group or default_group_name -- Use provided group or the default

	-- Construct the macro string based on the provided parts
	local macro_string = "yo"
		.. config.prefix
		.. esc
		.. "p" -- Paste yanked text (variable name)
		.. "a" -- Append after pasted text
		.. config.separator
		.. esc
		.. "p" -- Paste yanked text again (variable value)
		.. "a" -- Append after pasted text
		.. config.suffix
		.. esc

	-- Create the autocommand for the specified filetypes
	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		pattern = config.filetypes,
		desc = "Setup log macro @" .. register .. " for " .. table.concat(config.filetypes, ", "),
		callback = function(args)
			-- Use vim.schedule to ensure setreg happens safely in the callback context
			vim.schedule(function()
				vim.fn.setreg(register, macro_string)
				-- Optional: Notify user that the macro is set for this buffer
				-- vim.notify("Log macro @" .. register .. " set for " .. args.match, vim.log.levels.INFO, { title = "Log Macro" })
			end)
		end,
	})
end
function M.setup()
	-- Setup for JavaScript and TypeScript (and React variants)
	M.setup_log_macro({
		filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
		register = "l", -- The register to use (e.g., @l)
		prefix = "console.log('",
		separator = ":', ",
		suffix = ");",
	})

	-- Setup for Go
	M.setup_log_macro({
		filetypes = { "go" },
		register = "l", -- Can use the same register, will be set based on filetype
		prefix = 'fmt.Println("',
		separator = ':", ',
		suffix = ")",
	})

	-- Setup for Python (using f-string)
	M.setup_log_macro({
		filetypes = { "python" },
		register = "l",
		prefix = 'print(f"',
		separator = " = {", -- Puts var name in string, then uses var value in {}
		suffix = '}")',
		-- Macro will produce: print(f"yanked_var = {yanked_var}")
	})

	-- Setup for Rust (using debug print)
	M.setup_log_macro({
		filetypes = { "rust" },
		register = "l",
		prefix = 'println!("',
		separator = ': {:?}", ', -- Use the debug formatter {:?}
		suffix = ");",
		-- Macro will produce: println!("yanked_var: {:?}", yanked_var);
	})
end
return M -- Return the module table containing the function
