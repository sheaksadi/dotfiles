return {
  {
    "mbbill/undotree",
    lazy = false,
    config = function()
      vim.keymap.set("n", "<F5>", vim.cmd.UndotreeToggle)

      -- Settings to increase undo history size
      vim.g.undotree_WindowLayout = 3 -- Display diff panel alongside undo tree
      vim.g.undotree_SplitWidth = 35 -- Set the width of the undotree window
      vim.g.undotree_DiffpanelHeight = 10 -- Set the height of the diff panel
      vim.g.undotree_SetFocusWhenToggle = 1 -- Focus on the undotree window when opened
      vim.g.undotree_HelpLine = 0 -- Hide help message at the bottom

      -- Ensure large undo history
      vim.opt.undofile = true -- Enable persistent undo
      vim.opt.undolevels = 10000 -- Increase maximum undo levels
      vim.opt.undoreload = 100000 -- Max bytes to save for undo
    end,
  },
}
