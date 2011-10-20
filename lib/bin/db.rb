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
	def migrate(*argv)
		path = '/db/migrations'
		unless File.directory?(Dir.pwd + path)
			empty_directory Dir.pwd + path
		end

		count = Dir[Dir.pwd + path + '/*.rb'].count + 1

		operate, table = argv.shift.split(":")
		file = Dir.pwd + path + "/#{count}_#{operate}_#{table}.rb"

		content = "Sequel.migration do\n"
		content << "\tchange do\n"
		
		if operate == "drop" or operate == "rename"
			content << "\t\t#{operate}_table(#{argv.to_s.gsub(",", ", ")})\n"
		else
			content << "\t\t#{operate}_table(:#{table}) do\n"
			argv.each do |item|
				content << "\t\t\t#{item.sub(":", " :").gsub(",", ", ")}\n"
			end
			content << "\t\tend\n"
		end

		content << "\tend\n"
		content << "end\n"
		create_file file, content

		say "Implementing complete!", "\e[32m"
	end

	desc "migration [VERSION] [OPERATE]", "Running the migrations"
	def migration(version = nil, operate = 'up')
		mpath = Dir.pwd + '/db/migrations'
		epath = Dir.pwd + '/environment.rb'
		if File.exist?(epath) and File.exist?(mpath)
			require epath
			dbcont = "'#{ENV['DATABASE_URL']}'"
			if operate == 'up'
				if version == nil
					run("sequel -m #{mpath} #{dbcont}")
				else
					run("sequel -m #{mpath} -M #{version} #{dbcont}")
				end
			else
				run("sequel -d #{dbcont} > #{Dir.pwd}/db/migration.rb")
			end
			say "Implementing complete!", "\e[32m"
		else
			say "No migrattion record file, please check out the correct path of the file", "\e[31m"
		end
	end

end
