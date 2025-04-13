return {
  {
    "rcarriga/nvim-notify",
    config = function()
      local notify = require("notify")
      vim.notify = notify
      notify.setup({
        timeout = 3000,
        max_width = 80,
        max_height = 20,
        stages = "fade",
      })

      -- Command to show notification history
      vim.api.nvim_create_user_command("NotificationHistory", function()
        require("notify").history()
      end, {})
    end,
  },
}
