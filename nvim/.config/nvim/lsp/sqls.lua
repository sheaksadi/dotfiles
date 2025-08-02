return {
	filetypes = { "sql", "pgsql" },
	settings = {
		sqls = {
			connections = {
				-- Example for PostgreSQL:
				-- {
				--   driver = "postgresql",
				--   dataSourceName = "host=localhost port=5432 user=postgres password=password dbname=postgres sslmode=disable",
				-- },
				-- Example for MySQL:
				-- {
				--   driver = "mysql",
				--   dataSourceName = "user:password@tcp(localhost:3306)/dbname",
				-- }
			},
		},
	},
	on_attach = function(client, _)
		-- Disable formatting from sqls (let null-ls handle it)
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
}
