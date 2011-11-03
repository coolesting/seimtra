class SeimtraThor < Thor
	desc "db_schema [PATH]", "Initialize a database with a schema"
	def db_schema(spath = "/db/schema.rb")
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

	desc "db_migration [PATH]", "Implement the migrations record for the database"
	method_options :run => :boolean, :dump => :string, :v => :numeric, :focus => :string
	def db_migration(*argv)
		options[:focus] ||= SCFG.get("module_focus")
		path = "/modules/#{options[:focus]}/migrations"
		unless File.directory?(Dir.pwd + path)
			empty_directory Dir.pwd + path
		end

		if argv.count > 0
			operate, table = argv.shift.split(":")
			file = Dir.pwd + path + 
				"/#{Time.now.strftime("%Y%m%d%H%M%S")}_#{operate}_#{table}.rb"

			create_file file do
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
			end
		end

		if options.run? or options[:dump] != nil
			mpath 	= Dir.pwd + path
			epath 	= Dir.pwd + '/environment.rb'

			return say "No migrattion record file, please check #{mpath}",
				"\e[31m" unless File.exist?(epath) and File.exist?(mpath)
			require epath

			dump 	= options[:dump] == 'd' ? '-d' : '-D'
			dbcont 	= "'#{ENV['DATABASE_URL']}'"
			version	= options[:v] == nil ? '' : "-M #{options[:v]}"
		end

 		if options.run?
			run("sequel -m #{mpath} #{version} #{dbcont}")
		end

		if options[:dump] != nil
			run("sequel #{dump} #{dbcont} > #{Dir.pwd}/modules/#{SCFG.get("module_focus")}/schema_#{Time.now.strftime('%Y%m%d%H%M%S')}.rb")
		end

		say "Implementing complete!", "\e[32m"
	end

end
