return {
	{
		"goolord/alpha-nvim",
		dependencies = { "folke/persistence.nvim" }, -- For session management
		config = function()
			local dashboard = require("alpha.themes.dashboard")

			-- Check if a session exists (using persistence.nvim)
			local function has_session()
				return require("persistence").list() ~= nil
			end

			-- Restore last session automatically if it exists
			if has_session() then
				require("persistence").load()
			end

			-- Modified dashboard buttons
			dashboard.section.buttons.val = {
				dashboard.button("e", "  New File", ":ene <BAR> startinsert<CR>"),
				dashboard.button("f", "  Find File", ":Telescope find_files<CR>"),
				dashboard.button("r", "  Recent Files", ":Telescope oldfiles<CR>"),
				dashboard.button("g", "  Find Word", ":Telescope live_grep<CR>"),
				dashboard.button("s", "  Restore Session", ":lua require('persistence').load()<CR>"),
				dashboard.button(
					"l",
					"  Restore Last Session",
					":lua require('persistence').load({ last = true })<CR>"
				),
				dashboard.button("c", "  Config", ":e ~/.config/nvim/init.lua<CR>"),
				dashboard.button("q", "  Quit", ":qa<CR>"),
			}

			-- Optional: Display session status in the header
			dashboard.section.header.val = {
				" ",
				"Neovim Dashboard",
				" ",
				has_session() and "󰦛  Session available (press 's' to restore)" or "󰚌  No session found",
				" ",
			}

			require("alpha").setup(dashboard.config)
		end,
	},
	-- Session management plugin
	{
		"folke/persistence.nvim",
		event = "BufReadPre",
		opts = { options = { "buffers", "curdir", "tabpages", "winsize", "help" } },
	},
}
