-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Set indentation to 4 spaces
vim.opt.tabstop = 4 -- Number of spaces that a <Tab> in the file counts for
vim.opt.shiftwidth = 4 -- Number of spaces to use for each step of (auto)indent
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.smartindent = true -- Enable smart indentation

-- Set fd as Telescope's default file finder
require("telescope").setup({
  defaults = {
    file_ignore_patterns = { "node_modules", "dist", ".next", ".nuxt", ".cache" },
    vimgrep_arguments = {
      "rg",
      "--hidden", -- Include hidden files
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
    },
  },
  pickers = {
    find_files = {
      find_command = { "fdfind", "--type", "f", "--hidden", "--no-ignore", "--exclude", "node_modules" },
    },
  },
})
