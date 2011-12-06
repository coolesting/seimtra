class SeimtraThor < Thor

	method_option :path, :type => :string, :default => "/db/schema.rb", :aliases => '-p'
	method_option :output, :type => :boolean, :aliases => '-o', :banner => 'Output the db schema'
	desc "schema", "Initialize a database with a schema"
	def schema
		spath 	= Dir.pwd + options[:path]
		db 		= Db.new
		return error(db.msg) if db.error

		return error("No schema at #{spath}") unless File.exist?(spath)
		require spath

		if options.output?
			say "Your database adapter is " + db.scheme, "\e[32m"
			say "Your database schema as the following : ", "\e[32m"
			say "\n"

			rows = []
			db.tables.each do |table|
				rows << [table.to_s]
				db.schema(table).each do |column, attr|
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

	##
	# = migration database record
	#
	# 
	# == arguments
	#
	# operate_table, string, such as, create:books, alter:books/
	# fields, 		 array, ["String:name","String:password"]	
	#
	#
	# == options
	#
	# --autocomplete, -a completing the fileds with primary_key, and timestamp, 
	# 				automatically
	# --run, -r		run the migration record
	# --dump		rollback the migration record, as the parameter of sequel
	# --module		specify a module for implementing the migrating action
	# --version, -v	specify a version for migrating record
	#
	# == examples
	#
	#	3s m drop :table1,:table2,:table3
	#	3s m rename :old_table,:new_table
	#
	#	3s m create:table_name primary_key:uid String:name String:pawd
	#	3s m alter:table_name drop_column:column_name
	#	3s m alter:table_name rename_column:old_column_name,:new_column_name
	#
	# create and run the migration records
	#
	# 	3s m table String:title text:body -a -r
	#

	method_option :autocomplete, :type => :boolean, :aliases => '-a'
	method_option :run, :type => :boolean, :aliases => '-r' 
	method_option :dump, :type => :string
	method_option :module, :type => :string
	method_option :version, :type => :numeric, :aliases => '-v' 
	desc "migration [OPERATER]:[TABLE] [FIELDS]", "Create/Run the migrations record for the database"
	def migration(operate_table = nil, *argv)

		#initialize data
		module_current	= options[:module] == nil ? SCFG.get("module_focus") : options[:module]
		path 			= "/modules/#{module_current}/migrations"
		mpath 			= Dir.pwd + path
		operate 		= table = ''
		default_operate	= ['create', 'alter', 'drop', 'rename']

		unless File.directory?(mpath)
			empty_directory mpath
		end

 		if operate_table != nil
			if operate_table.index(':')
				operate, table = operate_table.split(":")
			else
				operate = 'create'
				table	= operate_table
			end

			unless default_operate.include?(operate) 
				return error("#{operate} is a error operation, you allow to use create, alter, rename and drop") 
			end
		end

		#create file for migrating record
		if operate != '' and table != '' and argv.count > 0
			file = mpath + "/#{Time.now.strftime("%Y%m%d%H%M%S")}_#{operate}_#{table}.rb"

			#auto add the primary_key and time to migrating record
			if options.autocomplete?
				db = Db.new
				return error db.msg if db.error
				argv = db.autocomplete(table, argv) if operate == 'create'
			end
	
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

		#setting the running environment
		if options.run? or options[:dump] != nil
			db = Db.new
			return error(db.msg) if db.error

			return error "No migrattion record file, please check #{mpath}" unless File.exist?(mpath)

			dump 	= options[:dump] == 'd' ? '-d' : '-D'
# 			dbcont 	= "'#{ENV['DATABASE_URL']}'"
			dbcont 	= "'#{settings.db_connect}'"
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
