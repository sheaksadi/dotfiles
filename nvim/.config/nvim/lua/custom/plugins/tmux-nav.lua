return {
  {
    "christoomey/vim-tmux-navigator",
    lazy = false, -- Ensure it loads immediately
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<CR>", desc = "Navigate left" },
      { "<C-j>", "<cmd>TmuxNavigateDown<CR>", desc = "Navigate down" },
      { "<C-k>", "<cmd>TmuxNavigateUp<CR>", desc = "Navigate up" },
      { "<C-l>", "<cmd>TmuxNavigateRight<CR>", desc = "Navigate right" },
      { "<C-\\>", "<cmd>TmuxNavigatePrevious<CR>", desc = "Navigate previous" },
    },
  },
}
