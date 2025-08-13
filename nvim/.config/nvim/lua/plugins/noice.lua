return {
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {

			views = {
				mini = {
					timeout = 4000,
				},
			},
		},
		dependencies = {
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			"MunifTanjim/nui.nvim",
			-- OPTIONAL:
			--   `nvim-notify` is only needed, if you want to use the notification view.
			--   If not available, we use `mini` as the fallback
			"rcarriga/nvim-notify",
		},
	},
	{
		"rcarriga/nvim-notify",
		enabled = false,
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
