return {
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup({})
		end,
	},
	-- Highlight todo, notes, etc in comments
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},

	{ -- Autoformat
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
		},
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				-- Disable "format_on_save lsp_fallback" for languages that don't
				-- have a well standardized coding style. You can add additional
				-- languages here or re-enable it for the disabled ones.
				local disable_filetypes = { c = true, cpp = true }
				if disable_filetypes[vim.bo[bufnr].filetype] then
					return nil
				else
					return {
						timeout_ms = 500,
						lsp_format = "fallback",
					}
				end
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				-- Conform can also run multiple formatters sequentially
				-- python = { "isort", "black" },
				--
				-- You can use 'stop_after_first' to run the first available formatter from the list
				-- javascript = { "prettierd", "prettier", stop_after_first = true },
			},
		},
	},
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			vim.keymap.set("n", "<S-h>", function() require('bufferline').cycle(-1) end, { desc = "Prev buffer" })
			vim.keymap.set("n", "<S-l>", function() require('bufferline').cycle(1) end, { desc = "Next buffer" })
			vim.keymap.set("n", "<leader>bc", function() vim.cmd('w') vim.cmd('bdelete!') end, { desc = "Close current buffer" })
			vim.keymap.set("n", "<C-z>", function() vim.cmd('w') vim.cmd('bdelete!') end, { desc = "Close current buffer" })
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
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {
			indent = {
				char = "│", -- more visible indent line like lazyvim
				-- tab_char = "│",
			},
			scope = {
				enabled = false,
				show_start = false,
				show_end = false,
				-- highlight = { "function", "label" },
			},
			exclude = {
				filetypes = {
					"help",
					"alpha",
					"dashboard",
					"neo-tree",
					"trouble",
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
		"karb94/neoscroll.nvim",
		config = function()
			require("neoscroll").setup({
				-- Put options here
				mappings = {
					"<C-u>",
					"<C-d>",
					"<C-b>",
					"<C-f>",
					"<C-y>",
					"<C-e>",
					"zt",
					"zz",
					"zb",
				},
				hide_cursor = false, -- Hide cursor while scrolling
				stop_eof = true, -- Stop at end of file
				respect_scrolloff = false, -- Stop at scrolloff value
				cursor_scrolls_alone = true, -- Cursor moves while scrolling
				easing_function = "sine", -- Options: quadratic, cubic, quartic, quintic, circular, sine
				-- post_hook = function()
				-- 	vim.cmd("normal! zz")
				-- end,
			})
		end,
	},
}
