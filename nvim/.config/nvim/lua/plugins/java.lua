return {
	{
		"mfussenegger/nvim-jdtls",
		ft = "java",
		config = function()
			local java_home = "/usr/lib/jvm/java-21-openjdk"
			local jdtls_bin = vim.fn.expand("~/.local/share/nvim/mason/bin/jdtls")

			local function get_workspace()
				local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
				return vim.fn.expand("~/.local/share/eclipse-workspace/") .. project_name
			end

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "java",
				callback = function()
					local config = {
						cmd = {
							jdtls_bin,
							"--java-executable",
							java_home .. "/bin/java",
							"-data",
							get_workspace(),
							"--jvm-arg=-Djava.awt.headless=true",
							"-clean",
						},
						root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
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
											path = java_home .. "/",
										},
									},
								},
							},
						},
						init_options = {
							bundles = {},
						},
					}
					require("jdtls").start_or_attach(config)
				end,
			})
		end,
	},
}
