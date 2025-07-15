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

vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "[R]e[n]ame" })
local map = vim.keymap.set

-- Clear search highlight
map("n", "<leader>nh", ":nohlsearch<CR>", { desc = "Clear search highlights" })

-- Increment/decrement numbers
map("n", "<leader>+", "<C-a>", { desc = "Increment number" })
map("n", "<leader>-", "<C-x>", { desc = "Decrement number" })

-- Move text up and down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected text down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected text up" })

-- Keep cursor centered while searching
map("n", "n", "nzzzv", { desc = "Next search result centered" })
map("n", "N", "Nzzzv", { desc = "Previous search result centered" })

-- Join lines without moving cursor
map("n", "J", "mzJ`z", { desc = "Join line without moving cursor" })

-- Paste without losing current register
map("x", "<leader>p", [["_dP]], { desc = "Paste without replacing register" })

-- Delete without copying to register
map("n", "<leader>d", [["_d]], { desc = "Delete without copying" })
map("v", "<leader>d", [["_d]], { desc = "Delete selection without copying" })

-- Quickfix list navigation
map("n", "<C-n>", ":cnext<CR>zz", { desc = "Next quickfix item" })
map("n", "<C-p>", ":cprev<CR>zz", { desc = "Previous quickfix item" })

-- Tab navigation
map("n", "<leader>to", ":tabnew<CR>", { desc = "Open new tab" })
map("n", "<leader>tx", ":tabclose<CR>", { desc = "Close tab" })
map("n", "<leader>tn", ":tabn<CR>", { desc = "Next tab" })
map("n", "<leader>tp", ":tabp<CR>", { desc = "Previous tab" })

-- Git keybinds (if using LazyGit)
map("n", "<leader>gg", ":LazyGit<CR>", { desc = "Open LazyGit" })

-- Keep cursor centered when scrolling
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })

-- Keep cursor centered when jumping through the jumplist
map("n", "<C-o>", "<C-o>zz", { desc = "Jump back and center" })
map("n", "<C-i>", "<C-i>zz", { desc = "Jump forward and center" })

-- Increase split size
vim.keymap.set("n", "<A-Left>", ":vertical resize -5<CR>", { desc = "Decrease width" })
vim.keymap.set("n", "<A-Right>", ":vertical resize +5<CR>", { desc = "Increase width" })
vim.keymap.set("n", "<A-Up>", ":resize +5<CR>", { desc = "Increase height" })
vim.keymap.set("n", "<A-Down>", ":resize -5<CR>", { desc = "Decrease height" })
-- Keymaps from essentials.lua
vim.keymap.set("n", "<leader>f", function() require("conform").format({ async = true, lsp_format = "fallback" }) end, { desc = "[F]ormat buffer" })
local map = vim.keymap.set
local opts = { noremap = true, silent = true }
map("n", "<S-H>", "<cmd>BufferLineCyclePrev<cr>", opts)
map("n", "<S-L>", "<cmd>BufferLineCycleNext<cr>", opts)


-- Keymaps from gitsigns.lua
do
  local gs = package.loaded.gitsigns

  local function map(mode, l, r, opts)
    opts = opts or {}
    opts.buffer = bufnr
    vim.keymap.set(mode, l, r, opts)
  end

  -- Navigation
  map("n", "]c", function()
    if vim.wo.diff then
      return "]c"
    end
    vim.schedule(function()
      gs.next_hunk()
    end)
    return "<Ignore>"
  end, { expr = true, desc = "Next hunk" })

  map("n", "[c", function()
    if vim.wo.diff then
      return "[c"
    end
    vim.schedule(function()
      gs.prev_hunk()
    end)
    return "<Ignore>"
  end, { expr = true, desc = "Previous hunk" })

  -- Actions
  map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage hunk" })
  map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk" })
  map("v", "<leader>hs", function()
    gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
  end, { desc = "Stage selected hunk" })
  map("v", "<leader>hr", function()
    gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
  end, { desc = "Reset selected hunk" })
  map("n", "<leader>hS", gs.stage_buffer, { desc = "Stage buffer" })
  map("n", "<leader>hR", gs.reset_buffer, { desc = "Reset buffer" })
  map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
  map("n", "<leader>hi", gs.preview_hunk_inline, { desc = "Preview hunk inline" })
  map("n", "<leader>hb", function()
    gs.blame_line({ full = true })
  end, { desc = "Blame line" })
  map("n", "<leader>hd", gs.diffthis, { desc = "Diff this" })
  map("n", "<leader>hD", function()
    gs.diffthis("~")
  end, { desc = "Diff against last commit" })
  map("n", "<leader>hq", gs.setqflist, { desc = "Send hunks to quickfix" })

  -- Toggles
  map("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "Toggle line blame" })
  map("n", "<leader>td", gs.toggle_deleted, { desc = "Toggle deleted" })
  map("n", "<leader>tw", gs.toggle_word_diff, { desc = "Toggle word diff" })
  map("n", "<leader>tl", gs.toggle_linehl, { desc = "Toggle line highlight" })

  -- Text object
  map({ "o", "x" }, "ih", gs.select_hunk, { desc = "Select hunk" })
end


-- Keymaps from oil.lua
vim.keymap.set("n", "<leader>e", function()
  local oil = require("oil")
  if oil.get_current_dir() then
    oil.close()
  else
    oil.open_float()
  end
end, { desc = "File Explorer (Oil)" })

vim.keymap.set("n", "<c-s>", function()
  local oil = require("oil")
  if oil.get_current_dir() then
    oil.save()
  else
    vim.cmd("w")
  end
end, { desc = "File Explorer (Oil)" })


-- Keymaps from tabout.lua
vim.keymap.set("i", "<C-l>", "<Tab>", { noremap = true })


-- Keymaps from tmux-nav.lua
vim.keymap.set("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>", { desc = "Navigate left" })
vim.keymap.set("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>", { desc = "Navigate down" })
vim.keymap.set("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>", { desc = "Navigate up" })
vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>", { desc = "Navigate right" })
vim.keymap.set("n", "<C-\\>", "<cmd>TmuxNavigatePrevious<CR>", { desc = "Navigate previous" })


-- Keymaps from undo-tree.lua
vim.keymap.set("n", "<F5>", vim.cmd.UndotreeToggle)







