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
	jsonls = {},
	yamlls = {},
	bashls = {},
	pyright = {
		settings = {
			python = {
				analysis = {
					autoSearchPaths = true,
					diagnosticMode = "workspace",
					useLibraryCodeForTypes = true,
					typeCheckingMode = "basic",
				},
			},
		},
	},
	jdtls = {
		-- 1. ADD THIS: Force Neovim to use the system jdtls you installed (bypass Mason/mise bugs)
		-- (Only uncomment this if you installed it via pacman/yay)
		-- cmd = { '/usr/bin/jdtls' },
		--
		cmd = {
			"env",
			"JAVA_HOME=" .. vim.fn.expand("~/.local/share/mise/installs/java/21.0.2"),
			vim.fn.expand("~/.local/share/nvim/mason/bin/jdtls")
		},
		settings = {
			java = {
				project = {
					referencedLibraries = {
						"lib/**/*.jar",
						"lib/*.jar",
					},
				},
				signatureHelp = { enabled = true },
				contentProvider = { preferred = "fernflower" },
				completion = {
					favoriteStaticMembers = {
						"org.junit.Assert.*",
						"org.junit.jupiter.api.Assertions.*",
						"org.mockito.Mockito.*",
					},
					filteredTypes = {
						"com.sun.*",
						"io.micrometer.shaded.*",
						"java.awt.*",
						"jdk.*",
						"sun.*",
					},
				},
				sources = {
					organizeImports = {
						starThreshold = 9999,
						staticStarThreshold = 9999,
					},
				},
				codeGeneration = {
					toString = {
						template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
					},
					useBlocks = true,
				},
				configuration = {
					runtimes = {
						{
							name = "JavaSE-21",
							-- 2. FIX THIS: Point exactly to your mise Java 21 installation!
							path = vim.fn.expand("~/.local/share/mise/installs/java/21.0.2/"),
						},
					},
				},
			},
		},
	},
}

local ensure_installed = vim.tbl_keys(servers or {})
vim.list_extend(ensure_installed, {})

for name, opts in pairs(servers) do
	vim.lsp.config(name, opts)
	vim.lsp.enable(name)
end

require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
