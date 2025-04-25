-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })
--

-- Add a keybinding to open Telescope in your config directory
vim.keymap.set("n", "<leader>fc", function()
	require("telescope.builtin").find_files({
		prompt_title = "< Neovim Config >",
		cwd = "~/.config/nvim",
	})
end, { desc = "Find in Neovim config" })

-- Keep visual selection after shifting >
vim.keymap.set("x", ">", ">gv", { desc = "Indent right and keep selection" })

-- Keep visual selection after shifting <
vim.keymap.set("x", "<", "<gv", { desc = "Indent left and keep selection" })

-- Save with Ctrl+S in normal and insert mode
vim.keymap.set("n", "<C-s>", ":w<CR>", { desc = "Save file" })
vim.keymap.set("i", "<C-s>", "<Esc>:w<CR>a", { desc = "Save file (insert mode)" })
vim.keymap.set("v", "<C-s>", "<Esc>:w<CR>", { desc = "Save file (visual mode)" })

-- VISUAL MODE: p (paste after) - Preserves clipboard
vim.keymap.set("x", "p", function()
	local clipboard_content = vim.fn.getreg("+")
	local clipboard_type = vim.fn.getregtype("+")
	vim.cmd('normal! "_dP') -- Delete selection, paste before (simulates 'p' in Visual mode)
	vim.fn.setreg("+", clipboard_content, clipboard_type)
end, { desc = "Paste after selection (keep clipboard)" })

-- VISUAL MODE: P (paste before) - Preserves clipboard
vim.keymap.set("x", "P", function()
	local clipboard_content = vim.fn.getreg("+")
	local clipboard_type = vim.fn.getregtype("+")
	vim.cmd('normal! "_dp') -- Delete selection, paste after (simulates 'P' in Visual mode)
	vim.fn.setreg("+", clipboard_content, clipboard_type)
end, { desc = "Paste before selection (keep clipboard)" })
