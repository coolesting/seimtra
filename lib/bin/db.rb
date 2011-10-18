class SeimtraThor < Thor
	desc "schema [PATH]", "Initialize a database with a schema"
	def schema(path = nil)
		puts "implements a schema"
	end

	desc "migrate [PATH]", "Implement a migration record for the database"
	def migrate(path = nil)
		puts "implements a migration"
	end
end
