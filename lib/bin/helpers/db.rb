class SeimtraThor < Thor

	method_option :path, :type => :string, :default => "/db/schema.rb", :aliases => '-p'
	method_option :output, :type => :boolean, :aliases => '-o', :banner => 'Output the db schema'
	desc "db_schema", "Initialize a database with a schema"
	def db_schema
		spath 	= Dir.pwd + options[:path]
		dh 		= Db_helper.new
		return say(dh.msg, '\e[31m') if dh.error

		return say("No schema at #{spath}", "\e[31m") unless File.exist?(spath)
		require spath

		if options.output?
			say "Your database adapter is " + DB.class.adapter_scheme.to_s, "\e[32m"

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
			puts rows
			#print_table(rows)
		end
		say "Implementing complete!", "\e[32m"

	end

	method_option :autocomplete, :type => :boolean, :aliases => '-a'
	method_option :run, :type => :boolean, :aliases => '-r' 
	method_option :dump, :type => :string
	method_option :module, :type => :string
	method_option :version, :type => :numeric, :aliases => '-v' 
	desc "db_migration [OPERATER]:[TABLE] [FIELDS]", "Create/Run the migrations record for the database"
	def db_migration(operate_table, *argv)

		#initialize data
		module_current = options[:module] == nil ? SCFG.get("module_focus") : options[:module]
		path = "/modules/#{module_current}/migrations"
		unless File.directory?(Dir.pwd + path)
			empty_directory Dir.pwd + path
		end

		operate = table = nil
		default_operate	= ['create', 'alter', 'drop', 'rename']
		operate, table 	= operate_table.split(":") if operate_table != nil
		unless default_operate.include?(operate) 
			return say("#{operate} is a error operation, you allow to use create, alter, rename and drop", "\e[31m") 
		end

		#create file for migrating record
		if operate != nil and argv.count > 0
			file = Dir.pwd + path + "/#{Time.now.strftime("%Y%m%d%H%M%S")}_#{operate}_#{table}.rb"

			#auto add the primary_key and time to migrating record
			if options.autocomplete?
				dh = Db_helper.new
				argv = dh.autocomplete(table, argv) if operate == 'create'
			end
	
			create_file file do
				content = "Sequel.migration do\n"
				content << "\tchange do\n"

				if operate == "drop" or operate == "rename"
					#3s dm drop :table1,:table2,:table3
					#3s dm rename :old_table,:new_table
					content << "\t\t#{operate}_table(#{argv.to_s.gsub(",", ", ")})\n"
				else
					#3s dm create:table_name primary_key:uid String:name String:pawd
					#3s dm alter:table_name drop_column:column_name
					#3s dm alter:table_name rename_column:old_column_name,:new_column_name
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

		#setting the running environment
		if options.run? or options[:dump] != nil
			mpath 	= Dir.pwd + path
			dh = Db_helper.new
			return say(dh.msg, '\e[31m') if dh.error

			return say "No migrattion record file, please check #{mpath}",
					"\e[31m" unless File.exist?(mpath)

			dump 	= options[:dump] == 'd' ? '-d' : '-D'
			dbcont 	= "'#{ENV['DATABASE_URL']}'"
			version	= options[:version] == nil ? '' : "-M #{options[:version]}"
		end

		#implement the migrations
 		if options.run?
			run("sequel -m #{mpath} #{version} #{dbcont}")
		end

		#dump the mrgrations
		if options[:dump] != nil
			run("sequel #{dump} #{dbcont} > #{Dir.pwd}/modules/#{module_current}/schema_#{Time.now.strftime('%Y%m%d%H%M%S')}.rb")
		end

		say "Implementing complete", "\e[32m"
	end

end
