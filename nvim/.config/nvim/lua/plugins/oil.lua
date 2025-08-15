return {
	{
		"stevearc/oil.nvim",
		lazy = false,
		dependencies = { { "echasnovski/mini.icons", opts = {} } },
		keys = {
			{
				"<leader>e",
				function()
					local oil = require("oil")
					if oil.get_current_dir() then
						oil.close()
					else
						oil.open_float()
					end
				end,
				desc = "File Explorer (Oil)",
			},
			desc = "File Explorer (Oil)",
			{
				"<c-s>",
				function()
					local oil = require("oil")
					if oil.get_current_dir() then
						oil.save()
					else
						vim.cmd("w")
					end
				end,
				desc = "File Explorer (Oil)",
			},
		},
		opts = {
			-- Use float window like snacks.nvim
			view_options = {
				show_hidden = true, -- Show dotfiles like snacks config
			},
			-- Float window configuration similar to snacks
			float = {
				padding = 2,
				max_width = 80,
				max_height = 30,
				border = "rounded",
				win_options = {
					winblend = 0,
				},
				-- -- Position the float similar to snacks
				-- override = function(conf)
				-- 	return vim.tbl_extend("force", conf, {
				-- 		relative = "editor",
				-- 		row = 1,
				-- 		col = 1,
				-- 	})
				-- end,
			},
			keymaps = {
				["<C-s>"] = false, -- This will unbind Ctrl-s
			},
			-- Close after selecting a file
			cleanup_delay_ms = 0,
		},
		config = function(_, opts)
			require("oil").setup(opts)
			-- Close oil when opening a file
			vim.api.nvim_create_autocmd("BufEnter", {
				callback = function(args)
					if require("oil").get_current_dir() and vim.bo[args.buf].filetype ~= "oil" then
						vim.schedule(function()
							require("oil").close()
						end)
					end
				end,
			})
		end,
	},
}
