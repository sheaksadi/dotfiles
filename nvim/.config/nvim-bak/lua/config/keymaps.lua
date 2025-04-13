-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<M-t>", ":silent !~/bin/toggle-pane.sh<CR>", { silent = true })

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

-- Add a keybinding to open Telescope in your config directory
vim.keymap.set("n", "<leader>fc", function()
  require("telescope.builtin").find_files({
    prompt_title = "< Neovim Config >",
    cwd = "~/.config/nvim",
  })
end, { desc = "Find in Neovim config" })

vim.api.nvim_set_hl(0, "CursorLine", { bg = "none" })
vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "none" })
-- Only target diagnostic virtual text highlights
local virt_text_groups = {
  "DiagnosticVirtualTextError",
  "DiagnosticVirtualTextWarn",
  "DiagnosticVirtualTextInfo",
  "DiagnosticVirtualTextHint",
  "DiagnosticVirtualTextOk", -- If exists
  -- "LspInlayHint",
}
for _, group in ipairs(virt_text_groups) do
  local fg = vim.api.nvim_get_hl(0, { name = group }).fg
  vim.api.nvim_set_hl(0, group, { fg = fg })
end

vim.api.nvim_set_hl(0, "LspInlayHint", {
  fg = "#7d7d7d", -- Medium gray color
  bg = "none", -- No background
  italic = true, -- Slight emphasis
})

vim.api.nvim_set_hl(0, "LspInlayHintParameter", {
  fg = "#5d7d9d", -- Soft blue
  bg = "none",
  italic = true,
})

vim.api.nvim_set_hl(0, "LspInlayHintType", {
  fg = "#5d9d7d", -- Soft green
  bg = "none",
  italic = false,
})

-- Optional: Add subtle underline for better readability
vim.api.nvim_set_hl(0, "LspInlayHintUnderline", {
  fg = "none",
  bg = "none",
  underline = true,
  sp = "#3a3a3a", -- Underline color
})
