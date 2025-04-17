return {
	{
		"goolord/alpha-nvim",
		dependencies = { "folke/persistence.nvim" },
		config = function()
			local dashboard = require("alpha.themes.dashboard")

			-- Check if buffer has a valid file extension
			local function has_file_extension(buf)
				local name = vim.api.nvim_buf_get_name(buf)
				return name:match("%.[%w_]+%f[%z%W]$") ~= nil
			end

			-- Clean up buffers that don't have file extensions or are special buffers
			local function clean_buffers()
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					local name = vim.api.nvim_buf_get_name(buf)
					local is_terminal = name:match("^term://")
					local is_empty = name == ""
					local is_fugitive = name:match("^fugitive://")
					local is_neo_tree = name:match("^neo%-tree")
					local is_oil = name:match("^oil://")

					if
						not (has_file_extension(buf) or is_terminal or is_empty or is_fugitive or is_neo_tree or is_oil)
					then
						vim.api.nvim_buf_delete(buf, { force = true })
					end
				end
			end

			-- Check if a session exists
			local function has_session()
				local sessions = require("persistence").list()
				return sessions and #sessions > 0
			end

			-- Initial buffer cleanup
			clean_buffers()

			-- Load session if available
			if has_session() then
				require("persistence").load()
				clean_buffers()
			end

			-- Dashboard buttons
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

			require("alpha").setup(dashboard.config)
		end,
	},
	{
		"folke/persistence.nvim",
		event = "BufReadPre",
		opts = {
			options = { "buffers", "curdir", "tabpages", "winsize", "help" },
		},
	},
}
