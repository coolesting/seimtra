class SeimtraThor < Thor
	desc "schema [PATH]", "Initialize a database with a schema"
	def schema(spath = "/db/schema.rb")
		spath = Dir.pwd + spath
		epath = Dir.pwd + '/environment.rb'
		if File.exist?(spath) and File.exist?(epath)
			require epath
			require spath
			say "Implementing complete!", "\e[32m"
			say "Your database adapter is " + DB.class.adapter_scheme.to_s, "\e[32m"

=begin
			say "Your database schema as the following : ", "\e[32m"
			say "-----------------------------------------"

			rows = []
			DB.tables.each do |table|
				rows << [table.to_s]
				DB.schema(table).each do |column, attr|
					rows << [
						column.to_s, 
						attr[:type].to_s, 
						attr[:db_type], 
						attr[:allow_null].to_s, 
						attr[:primary_key].to_s, 
						attr[:default].to_s
					]
				end
			end
			p rows
			print_table(rows)
=end

		else
			say "No schema at #{spath}", "\e[31m"
		end
	end

	desc "migrate [PATH]", "Implement the migrations record for the database"
	def migrate(path = nil)
		say "Implementing complete!"
	end
end
