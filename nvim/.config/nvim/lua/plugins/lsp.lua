return {
	-- LSP Plugins
	{
		-- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
		-- used for completion, annotations and signatures of Neovim apis
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	{
		-- Main LSP Configuration
		"neovim/nvim-lspconfig",
		dependencies = {
			-- Automatically install LSPs and related tools to stdpath for Neovim
			-- Mason must be loaded before its dependents so we need to set it up here.
			-- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
			{ "williamboman/mason.nvim", opts = {} },
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

			-- Useful status updates for LSP.
			{ "j-hui/fidget.nvim", opts = {} },

			-- Allows extra capabilities provided by blink.cmp
			"saghen/blink.cmp",
		},
		config = function()
			-- Brief aside: **What is LSP?**
			--
			-- LSP is an initialism you've probably heard, but might not understand what it is.
			--
			-- LSP stands for Language Server Protocol. It's a protocol that helps editors
			-- and language tooling communicate in a standardized fashion.
			--
			-- In general, you have a "server" which is some tool built to understand a particular
			-- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
			-- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
			-- processes that communicate with some "client" - in this case, Neovim!
			--
			-- LSP provides Neovim with features like:
			--  - Go to definition
			--  - Find references
			--  - Autocompletion
			--  - Symbol Search
			--  - and more!
			--
			-- Thus, Language Servers are external tools that must be installed separately from
			-- Neovim. This is where `mason` and related plugins come into play.
			--
			-- If you're wondering about lsp vs treesitter, you can check out the wonderfully
			-- and elegantly composed help section, `:help lsp-vs-treesitter`

			--  This function gets run when an LSP attaches to a particular buffer.
			--    That is to say, every time a new file is opened that is associated with
			--    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
			--    function will be executed to configure the current buffer

			-- LSP servers and clients are able to communicate to each other what features they support.
			--  By default, Neovim doesn't support everything that is in the LSP specification.
			--  When you add blink.cmp, luasnip, etc. Neovim now has *more* capabilities.
			--  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
			--
			-- local capabilities = require("blink.cmp").get_lsp_capabilities()

			-- Enable the following language servers
			--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
			--
			--  Add any additional override configuration in the following tables. Available keys are:
			--  - cmd (table): Override the default command used to start the server
			--  - filetypes (table): Override the default list of associated filetypes for the server
			--  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
			--  - settings (table): Override the default settings passed when initializing the server.
			--        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
			local servers = {
				-- clangd = {},

				-- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
				--
				-- Some languages (like typescript) have entire language plugins that can be useful:
				--    https://github.com/pmizio/typescript-tools.nvim
				--
				-- But for many setups, the LSP (`ts_ls`) will work just fine

				-- ts_ls = {
				-- 	-- Disable ts_ls for .vue files to avoid conflicts with vue-language-server
				-- 	filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
				-- 	settings = {
				-- 		typescript = {
				-- 			tsserver = {
				-- 				useSyntaxServer = false,
				-- 			},
				-- 			inlayHints = {
				-- 				includeInlayParameterNameHints = "all",
				-- 				includeInlayParameterNameHintsWhenArgumentMatchesName = true,
				-- 				includeInlayFunctionParameterTypeHints = true,
				-- 				includeInlayVariableTypeHints = true,
				-- 				includeInlayVariableTypeHintsWhenTypeMatchesName = true,
				-- 				includeInlayPropertyDeclarationTypeHints = true,
				-- 				includeInlayFunctionLikeReturnTypeHints = true,
				-- 				includeInlayEnumMemberValueHints = true,
				-- 			},
				-- 		},
				-- 	},
				-- },

				-- vtsls = ,
				-- vue_ls = {},

				-- vue_ls = {
				-- 	init_options = {
				-- 		vue = {
				-- 			hybridMode = false,
				-- 		},
				-- 	},
				-- 	settings = {
				-- 		typescript = {
				-- 			inlayHints = {
				-- 				enumMemberValues = {
				-- 					enabled = true,
				-- 				},
				-- 				functionLikeReturnTypes = {
				-- 					enabled = true,
				-- 				},
				-- 				propertyDeclarationTypes = {
				-- 					enabled = true,
				-- 				},
				-- 				parameterTypes = {
				-- 					enabled = true,
				-- 					suppressWhenArgumentMatchesName = true,
				-- 				},
				-- 				variableTypes = {
				-- 					enabled = true,
				-- 				},
				-- 			},
				-- 		},
				-- 	},
				-- },
			}

			-- Ensure the servers and tools above are installed
			--
			-- To check the current status of installed tools and/or manually install
			-- other tools, you can run
			--    :Mason
			--
			-- You can press `g?` for help in this menu.
			--
			-- `mason` had to be setup earlier: to configure its options see thelsp
			-- `dependencies` table for `nvim-lspconfig` above.
			--
			-- You can add other tools here that you want Mason to install
			-- for you, so that they are available from within Neovim.
			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				-- Used to format Lua code
				-- "sqls",
				-- "vue-language-server",
				-- "vtsls",
			})
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
			-- local server_names = {}
			-- require("mason-lspconfig").setup({
			-- 	ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
			-- 	automatic_installation = false,
			-- 	handlers = {
			-- 		function(server_name)
			-- 			local server = servers[server_name] or {}
			-- 			-- This handles overriding only values explicitly passed
			-- 			-- by the server configuration above. Useful when disabling
			-- 			-- certain features of an LSP (for example, turning off formatting for ts_ls)
			-- 			-- server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
			-- 			-- require("lspconfig")[server_name].setup(server)
			-- 			-- vim.lsp.config(server_name, server)
			-- 			-- server_names.add(server_name)
			-- 			-- vim.lsp.enable(server_name)
			-- 		end,
			-- 	},
			-- })

			-- for server_name, server in ipairs(servers) do
			-- 	print(server_name)
			-- 	vim.lsp.config(server_name, server)
			-- 	server_names.add(server_name)
			-- end
			-- vim.lsp.enable(server_names)
			-- vim.notify("server_names:" .. server_names)
		end,
	},
}
