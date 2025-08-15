-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", function()
	vim.cmd("nohlsearch")
	local oil = require("oil")
	if oil.get_current_dir() then
		oil.close()
	end
end, { silent = true })
vim.keymap.set("n", "<leader>nh", ":nohlsearch<CR>", { desc = "Clear search highlights", silent = true })

-- Diagnostic keymaps
-- vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" }) TODO: learn to how to properly use this

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode", silent = true })

--  See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window", silent = true })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window", silent = true })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window", silent = true })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window", silent = true })

-- Add a keybinding to open Telescope in your config directory
vim.keymap.set("n", "<leader>nc", function()
	require("telescope.builtin").find_files({
		prompt_title = "< Neovim Config >",
		cwd = "~/.config/nvim",
	})
end, { desc = "Find in [N]eovim [c]onfig", silent = true })

-- Keep visual selection after shifting >
vim.keymap.set("x", ">", ">gv", { desc = "Indent right and keep selection", silent = true })

-- Keep visual selection after shifting <
vim.keymap.set("x", "<", "<gv", { desc = "Indent left and keep selection", silent = true })

-- Save with Ctrl+S in normal and insert mode
-- vim.keymap.set("n", "<C-s>", ":w<CR><Esc>", { desc = "Save file" })
vim.keymap.set("i", "<C-s>", function()
	-- Dismiss completion menu if visible
	if vim.fn.pumvisible() == 1 then
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-e>", true, false, true), "n", false)
	end
	-- Exit insert mode and save
	vim.cmd("stopinsert")
	vim.cmd("w")
end, { desc = "Save file (insert mode)", silent = true })
vim.keymap.set("v", "<C-s>", "<Esc>:w<CR>", { desc = "Save file (visual mode)", silent = true })

-- VISUAL MODE: p (paste after) - Preserves clipboard
vim.keymap.set("x", "p", function()
	local clipboard_content = vim.fn.getreg("+")
	local clipboard_type = vim.fn.getregtype("+")
	vim.cmd('normal! "_dP') -- Delete selection, paste before (simulates 'p' in Visual mode)
	vim.fn.setreg("+", clipboard_content, clipboard_type)
end, { desc = "Paste after selection (keep clipboard)", silent = true })

-- VISUAL MODE: P (paste before) - Preserves clipboard
vim.keymap.set("x", "P", function()
	local clipboard_content = vim.fn.getreg("+")
	local clipboard_type = vim.fn.getregtype("+")
	vim.cmd('normal! "_dp') -- Delete selection, paste after (simulates 'P' in Visual mode)
	vim.fn.setreg("+", clipboard_content, clipboard_type)
end, { desc = "Paste before selection (keep clipboard)", silent = true })

vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "[R]e[n]ame", silent = true })

vim.keymap.set("n", "<leader>tm", function()
	if vim.o.mouse == "" then
		vim.opt.mouse = "a"
		vim.notify("Mouse enabled")
	else
		vim.opt.mouse = ""
		vim.notify("Mouse disabled")
	end
end, { desc = "Toggle mouse on/off", silent = true })

local function substitute(character)
	local firstline = vim.fn.line("v")
	local lastline = vim.fn.line(".")
	if firstline > lastline then
		firstline, lastline = lastline, firstline
	end
	vim.cmd(firstline .. "," .. lastline .. "s/\\(^\\s*- \\[\\).\\]/\\1" .. character .. "\\]")
	vim.cmd("nohlsearch")
end
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.keymap.set({ "n", "v" }, "<leader>x", function()
			substitute("x")
		end, { buffer = true, noremap = true, silent = true, desc = "check marks in markdown" })
	end,
})
