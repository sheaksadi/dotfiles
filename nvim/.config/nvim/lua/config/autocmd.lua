-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Close empty buffers automatically
vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		if vim.bo.buftype == "" and vim.fn.expand("%") == "" and vim.fn.line2byte("$") == -1 then
			vim.cmd("bd")
		end
	end,
})
-- Set up LSP keymap for quick actions
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		-- Just the essential code action keybind
		vim.keymap.set(
			{ "n", "v" }, -- Normal and Visual modes
			"<leader>a", -- Your quick action key
			vim.lsp.buf.code_action, -- The action to trigger
			{ buffer = args.buf, desc = "LSP: Quick actions" }
		)
	end,
})
-- -- Close directory buffer on startup to allow alpha to show
-- vim.api.nvim_create_autocmd("VimEnter", {
-- 	callback = function()
-- 		if vim.fn.argc() == 1 then
-- 			local arg = vim.fn.argv(0)
-- 			local stat = vim.loop.fs_stat(arg)
-- 			if stat and stat.type == "directory" then
-- 				vim.cmd("enew") -- Open empty buffer
-- 				vim.cmd("Alpha") -- Show Alpha dashboard
-- 			end
-- 		end
-- 	end,
-- })
--
-- vim.api.nvim_create_autocmd("VimEnter", {
-- 	callback = function()
-- 		-- Close all unnamed buffers
-- 		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
-- 			if vim.api.nvim_buf_get_name(buf) == "" then
-- 				vim.api.nvim_buf_delete(buf, { force = true })
-- 			end
-- 		end
-- 	end,
-- })
--
-- -- Preserve cursor column position when leaving insert mode
-- vim.api.nvim_create_autocmd("InsertLeave", {
-- 	pattern = "*",
-- 	callback = function()
-- 		local col = vim.fn.col(".") -- Get current column
-- 		-- Only adjust if we're on whitespace (indentation)
-- 		if vim.fn.getline("."):sub(1, col):match("^%s+$") then
-- 			vim.schedule(function()
-- 				vim.fn.cursor(0, col) -- Restore exact position
-- 			end)
-- 		end
-- 	end,
-- })
