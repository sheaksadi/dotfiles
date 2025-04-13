return {
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup({})
		end,
	},
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("bufferline").setup({
				options = {
					separator_style = "thin",
					show_buffer_close_icons = false,
					show_close_icon = false,
					modified_icon = "●",
					diagnostics = "nvim_lsp",
					always_show_bufferline = false,
				},
			})
		end,
	},
	{
		"goolord/alpha-nvim",
		config = function()
			require("alpha").setup(require("alpha.themes.dashboard").config)
		end,
	},

	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {
			indent = {
				char = "│", -- More visible indent line like LazyVim
				tab_char = "│",
			},
			scope = {
				enabled = true,
				show_start = false,
				show_end = false,
				highlight = { "Function", "Label" },
			},
			exclude = {
				filetypes = {
					"help",
					"alpha",
					"dashboard",
					"neo-tree",
					"Trouble",
					"trouble",
					"lazy",
					"mason",
					"notify",
					"toggleterm",
					"lazyterm",
				},
			},
		},
	},
	{
		"echasnovski/mini.indentscope",
		version = false,
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			symbol = "│",
			options = { try_as_border = true },
			draw = {
				animation = require("mini.indentscope").gen_animation.none(), -- No animation like LazyVim
			},
		},
		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = {
					"help",
					"alpha",
					"dashboard",
					"neo-tree",
					"Trouble",
					"trouble",
					"lazy",
					"mason",
					"notify",
					"toggleterm",
					"lazyterm",
				},
				callback = function()
					vim.b.miniindentscope_disable = true
				end,
			})

			-- LazyVim-style colors
			vim.api.nvim_create_autocmd("ColorScheme", {
				callback = function()
					-- Standard indent line color (subtle but visible)
					vim.api.nvim_set_hl(0, "IblIndent", { fg = "#3b4261" })

					-- Scope color (brighter, more visible)
					vim.api.nvim_set_hl(0, "IblScope", { fg = "#82aaff" })

					-- Mini indent color
					vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { fg = "#82aaff" })
				end,
			})
		end,
	},
}
