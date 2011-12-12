class SeimtraThor < Thor

	# = Schema
	#
	# output/dump the schema/migration from database

	# == options
	#
	# --dump		rollback the migration record, as the parameter of sequel

	# == examples
	#
	#	3s schema
	#	3s schema -d
	#
	# run the schema at db/schema.rb
	#
	# 	3s schema -r

	method_option :details, :type => :boolean, :aliases => '-d'
	method_option :run, :type => :boolean, :aliases => '-r'
	method_option :dump, :type => :boolean
	method_option :with, :type => :string
	desc "schema", "Initialize a database with a schema"
	def schema
		
		db 		= Db.new
		dbcont 	= "'#{settings.db_connect}'"
		output	= true
		return error(db.msg) if db.error

		#dump the mrgration from database
		if options[:dump]
			dump 	= options[:with] == 'D' ? '-D' : '-d'
			mpath = Dir.pwd + "/migrations"
			unless File.exist?(mpath)
				empty_directory mpath
			end
			run("sequel #{dump} #{dbcont} > #{Dir.pwd}/db/migrations/#{Time.now.strftime('%Y%m%d%H%M%S')}.rb")
		end

		if output
			say "The adapter :  #{db.get_scheme}.", "\e[32m"
			say "The schema as the following.", "\e[32m"
			puts "\n"

			#puts the tables of database to array of hash
			unless options.details?
				db.get_tables.each do |table|
					print table.to_s.ljust(20, ' ')
					print db.get_columns(table)
					print "\n"
				end
			else
				print db.dump_schema_migration
			end
		end
		say "\n"

	end


	# = migration database record
	#
	# Create and implement for migrations to database
	#

	# == arguments
	#
	# operate_table, string, such as, create:books, alter:books/
	# fields, 		 array, ["String:name","String:password"]	
	#

	# == options
	#
	# --autocomplete, -a completing the fileds with primary_key, and timestamp, 
	# 				automatically
	# --run, -r		run the migrations
	# --schema, -s	run the schema
	# --to,-t		specify a module for implementing the migrating action
	# --version, -v	specify a version for migrating record

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
	method_option :schema, :type => :boolean, :aliases => '-s' 
	method_option :to, :type => :string, :aliases => '-t' 
	method_option :version, :type => :numeric, :aliases => '-v' 
	desc "migration [OPERATER]:[TABLE] [FIELDS]", "Create/Run the migrations record for the database"
	def migration(operate_table = nil, *argv)

		#initialize data
		db 				= Db.new
		return error(db.msg) if db.error

		module_current	= options[:to] == nil ? SCFG.get("module_focus") : options[:to]
		path 			= "/modules/#{module_current}/migrations"
		mpath 			= Dir.pwd + path
		operate 		= table = ''
		default_operate	= ['create', 'alter', 'drop', 'rename']

		dbcont 			= "'#{settings.db_connect}'"
		version			= options[:version] == nil ? '' : "-M #{options[:version]}"

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
		if options.run? 
			return error "No migrattion record file, please check #{mpath}" unless File.exist?(mpath)
			run("sequel -m #{mpath} #{version} #{dbcont}")
		end

		#implement schema 
		if options.schema?
			spath = Dir.pwd + "/db/schema.rb"
			return error("No schema at #{spath}") unless File.exist?(spath)
			require spath
		end

		say "Implementing complete", "\e[32m"
	end

end
