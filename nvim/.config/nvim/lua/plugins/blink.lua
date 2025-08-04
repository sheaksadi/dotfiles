return {

	{ -- Autocompletion
		"saghen/blink.cmp",
		event = "VimEnter",
		version = "1.*",
		dependencies = {
			-- Snippet Engine
			{
				"L3MON4D3/LuaSnip",

				version = "2.*",
				build = (function()
					-- Build Step is needed for regex support in snippets.
					-- This step is not supported in many windows environments.
					-- Remove the below condition to re-enable on windows.
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
				dependencies = {
					-- `friendly-snippets` contains a variety of premade snippets.
					--    See the README about individual language/framework/plugin snippets:
					--    https://github.com/rafamadriz/friendly-snippets
					{
						"rafamadriz/friendly-snippets",
						config = function()
							-- will exclude all javascript snippets
							require("luasnip.loaders.from_vscode").load({
								exclude = { "javascript", "typescript" },
							})
						end,
					},
				},
				config = function()
					local ls = require("luasnip")
					-- ls.filetype_extend("typescript", { "javascript" })
					ls.config.set_config({
						-- history = true,
						updateevents = "TextChanged,TextChangedI",
						enable_autosnippets = true,
					})

					vim.keymap.set({ "i" }, "<C-K>", function()
						ls.expand()
					end, { silent = true })
					vim.keymap.set({ "i", "s" }, "<C-J>", function()
						ls.jump(1)
					end, { silent = true })
					vim.keymap.set({ "i", "s" }, "<C-H>", function()
						ls.jump(-1)
					end, { silent = true })

					vim.keymap.set({ "i", "s" }, "<C-L>", function()
						if ls.choice_active() then
							ls.change_choice(1)
						end
					end, { silent = true })
					vim.keymap.set("n", "<leader>ns", "<cmd>source ~/.config/nvim/lua/utils/snippets.lua<CR>")
				end,
				keys = {
					{
						"<C-f>",
						function()
							local ls = require("luasnip")
							if ls.expand_or_jumpable() then
								ls.expand_or_jump()
							end
						end,
						mode = { "i", "s" },
						silent = true,
						desc = "Snippet: Jump Forward",
					},
				},

				opts = {
					print,
				},
			},
			"folke/lazydev.nvim",
		},
		--- @module 'blink.cmp'
		--- @type blink.cmp.Config
		opts = {
			keymap = {
				-- 'default' (recommended) for mappings similar to built-in completions
				--   <c-y> to accept ([y]es) the completion.
				--    This will auto-import if your LSP supports it.
				--    This will expand snippets if the LSP sent a snippet.
				-- 'super-tab' for tab to accept
				-- 'enter' for enter to accept
				-- 'none' for no mappings
				--
				-- For an understanding of why the 'default' preset is recommended,
				-- you will need to read `:help ins-completion`
				--
				-- No, but seriously. Please read `:help ins-completion`, it is really good!
				--
				-- All presets have the following mappings:
				-- <tab>/<s-tab>: move to right/left of your snippet expansion
				-- <c-space>: Open menu or open docs if already open
				-- <c-n>/<c-p> or <up>/<down>: Select next/previous item
				-- <c-e>: Hide menu
				-- <c-k>: Toggle signature help
				--
				-- See :h blink-cmp-config-keymap for defining your own keymap
				preset = "default",
				["<C-a>"] = { "show", "show_documentation", "hide_documentation" },
				-- ["<Tab>"] = { "select_and_accept", "fallback" },
				-- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
				--    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
			},

			appearance = {
				-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
				-- Adjusts spacing to ensure icons are aligned
				nerd_font_variant = "mono",
			},

			sources = {
				default = { "lsp", "snippets", "buffer", "path", "lazydev" },
				per_filetype = {
					sql = { "snippets", "dadbod", "buffer" },
				},
				providers = {
					dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
					lsp = { score_offset = 1 },
					snippets = { score_offset = 2, min_keyword_length = 2 },
					buffer = { score_offset = 1 },
					path = { score_offset = 1 },
					lazydev = { module = "lazydev.integrations.blink", score_offset = 1 },
				},
			},
			menu = {
				scrollbar = false,
			},
			completion = {
				-- 'prefix' will fuzzy match on the text before the cursor
				-- 'full' will fuzzy match on the text before _and_ after the cursor
				-- example: 'foo_|_bar' will match 'foo_' for 'prefix' and 'foo__bar' for 'full'
				keyword = { range = "full" },
				ghost_text = {
					enabled = true,
					-- show_with_menu = false,
				},
				-- Disable auto brackets
				-- NOTE: some LSPs may add auto brackets themselves anyway
				accept = { auto_brackets = { enabled = true } },
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 200,
				},
				list = { selection = { preselect = true, auto_insert = false } },
			},

			snippets = { preset = "luasnip" },

			-- Blink.cmp includes an optional, recommended rust fuzzy matcher,
			-- which automatically downloads a prebuilt binary when enabled.
			--
			-- By default, we use the Lua implementation instead, but you may enable
			-- the rust implementation via `'prefer_rust_with_warning'`
			--
			-- See :h blink-cmp-config-fuzzy for more information
			fuzzy = { implementation = "lua" },

			-- Shows a signature help window while you type arguments for a function
			signature = { enabled = true, window = { border = "rounded", scrollbar = false } },
		},
	},
}
