local servers = {
	vtsls = {
		settings = {
			vtsls = {
				tsserver = {
					useSyntaxServer = false,

					globalPlugins = {
						{
							name = "@vue/typescript-plugin",
							location = vim.fn.stdpath("data")
								.. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
							languages = { "vue" },
							configNamespace = "typescript",
						},
					},
				},
			},
			typescript = {
				inlayHints = {
					parameterNames = {
						enabled = "all",
						suppressWhenArgumentMatchesName = true,
					},
					parameterTypes = {
						enabled = true,
					},
					variableTypes = {
						enabled = true,
					},
					propertyDeclarationTypes = {
						enabled = true,
					},
					functionLikeReturnTypes = {
						enabled = true,
					},
					enumMemberValues = {
						enabled = true,
					},
				},
			},
			javascript = {
				inlayHints = {
					parameterNames = {
						enabled = "all",
						suppressWhenArgumentMatchesName = true,
					},
					parameterTypes = {
						enabled = true,
					},
					variableTypes = {
						enabled = true,
					},
					propertyDeclarationTypes = {
						enabled = true,
					},
					functionLikeReturnTypes = {
						enabled = true,
					},
					enumMemberValues = {
						enabled = true,
					},
				},
			},
		},

		filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
	},
	lua_ls = {

		settings = {
			Lua = {
				completion = {
					callSnippet = "Replace",
				},
				-- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
				-- diagnostics = { disable = { 'missing-fields' } },
			},
		},
	},
	vue_ls = {},
	gopls = {},
	rust_analyzer = {},
	tailwindcss = {},
	stylua = {},
	jsonls = {},
	yamlls = {},
}

local ensure_installed = vim.tbl_keys(servers or {})
vim.list_extend(ensure_installed, {})

for name, opts in pairs(servers) do
	vim.lsp.config(name, opts)
	vim.lsp.enable(name)
end

require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
