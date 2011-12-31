class SeimtraThor < Thor

	# = Database operation 
	#
	# Create and implement for migrations to the database,
	# output/dump the schema/migration from database
	#
	# == Arguments
	#
	# operate_table, string, such as, create:books, alter:books/
	# fields, 		 array, ["String:name","String:password"]
	#
	# == Options
	#
	# --autocomplete, -a completing the fileds with primary_key, and timestamp, 
	# 				automatically
	# --run, -r		run the migrations
	# --to, -t		specify a module for implementing the migrating action
	# --version, -v	specify a version for migrating record
	# --dump, -d		dump the database schema to a migration file
	# --output, -o	output the schema of database
	# --with, -w	a hash as the parammeters
	#
	# == Examples
	#
	# create the migration
	#
	#	3s db drop :table1,:table2,:table3
	#	3s db rename :old_table,:new_table
	#
	#	3s db create:table_name primary_key:uid String:name String:pawd
	#	3s db alter:table_name drop_column:column_name
	#	3s db alter:table_name rename_column:old_column_name,:new_column_name
	#
	# create and run the migration records
	#
	# 	3s db table String:title text:body -a -r
	#
	# dump the db schema to migration
	#
	#	3s db -d
	#	3s db --dump --with=D
	#
	# run the schema at db/schema.rb
	#
	#	3s db -r -w=schema

	method_option :autocomplete, :type => :boolean, :aliases => '-a'
	method_option :run, :type => :boolean, :aliases => '-r' 
	method_option :to, :type => :string, :aliases => '-t' 
	method_option :version, :type => :numeric, :aliases => '-v' 
	method_option :dump, :type => :boolean, :aliases => '-d'
	method_option :output, :type => :boolean, :aliases => '-o'
	method_option :with, :type => :hash, :default => {}, :aliases => '-w'
	desc "db [OPERATOR:TABLE] [FIELDS]", "Create/Run the migrations, and output schema/migration of database"
	def db(operate_table = nil, *argv)

		#initialize data
		db 				= Db.new
		return error(db.msg) if db.error

		module_current	= options[:to] == nil ? SCFG.get(:module_focus) : options[:to]
		path 			= "/modules/#{module_current}/migrations"
		mpath 			= Dir.pwd + path
		gpath 			= Dir.pwd + "/db/migrations"
		operate 		= table = ''
		default_operate	= [:create, :alter, :drop, :rename]
		dbcont 			= "'#{settings.db_connect}'"
		version			= options[:version] == nil ? '' : "-M #{options[:version]}"

		empty_directory(gpath) unless File.exist?(gpath)
		empty_directory(mpath) unless File.directory?(mpath)

 		if operate_table != nil
			if operate_table.index(':')
				operate, table = operate_table.split(":")
			else
				operate = 'create'
				table	= operate_table
			end

			unless default_operate.include?(operate.to_sym) 
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

		#implement the migrations
		if options.run? 
			path = mpath
			if options[:with]['global']
				path = Dir[gpath + "/*"].sort.last
			end

			return error("No schema at #{path}") unless File.exist?(path)
			run("sequel -m #{path} #{version} #{dbcont}")
			say "Implementing complete", "\e[32m"
		end

		#dump the database schema to a  mrgration
		if options.dump?
			dump = options[:with]['dump'] == 'D' ? '-D' : '-d'
			run("sequel #{dump} #{dbcont} > #{gpath}/#{Time.now.strftime('%Y%m%d%H%M%S')}.rb")
		end

		#output the schema/migration
		if options.output?
			say "The adapter :  #{db.get_scheme}.", "\e[32m"
			say "The schema as the following.", "\e[32m"
			puts "\n"

			#puts the tables of database to array of hash
			if options[:with]["details"]
				print db.dump_schema_migration
			else
				db.get_tables.each do |table|
					print table.to_s.ljust(20, ' ')
					print db.get_columns(table)
					print "\n"
				end
			end
			say "\n"
		end

	end

end
