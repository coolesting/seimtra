class SeimtraThor < Thor

	long_desc <<-DOC
	== Description

	Create and implement the migration to database, output/dump the schema/migration from database

	== Arguments

	data, an array, the format of vaule as the following, 

	['field1', 'field2', 'field3']

	or

	['field1,primary_id', 'field2,String', 'field3,null:false']

	== Options

	--autocomplete, -a completing the field with primary_key, and timestamp, automatically

	--run, -r		run the migrations

	--to, -t		specify a module for implementing the migrating action

	--version, -v	specify a version for migrating record

	--dump, -d	dump the database schema to a migration file

	--output, -o	output the schema of database

	--details 	output with the details

	--schema		implement a global database schema

	== Examples

	dropdown, rename, create, alter to table :

		3s db drop table1 table2 table3

		3s db rename old_table new_table

		3s db table_name uid:primary_key name:string pawd:string

		3s db table_name name pawd -a

		3s db table_name name pawd email:string:null=false

		3s db alter table_name drop_column column_name

	create a database with two fields, and autocomplete primary_id, changed time, then run the migration records :

		3s db table_name title,String body,text -a -r

	dump the current db schema to a migration file (the default path at db/migrations) :

		3s db --dump=D

	implement a db schema using the default file at db/migrations :

		3s db -r --schema

	output the schema of current database :

		3s db -o

		3s db -od
	DOC

	method_option :autocomplete, :type => :boolean, :aliases => '-a'
	method_option :run, :type => :boolean, :aliases => '-r' 
	method_option :to, :type => :string, :aliases => '-t' 
	method_option :version, :type => :numeric, :aliases => '-v' 
	method_option :dump, :type => :string
	method_option :output, :type => :boolean, :aliases => '-o'
	method_option :details, :type => :boolean, :aliases => '-d'
	method_option :schema, :type => :boolean
	desc "db [MODULE_NAME]", "Create/Run the migrations, output schema/migration of database"
	def db module_name = nil
		#initialize data
		db 				= Sapi.new
		error(db.msg) if db.error
		time			= Time.now.strftime('%Y%m%d%H%M%S')
		dbcont 			= db.connect
		version			= options[:version] == nil ? '' : "-M #{options[:version]}"

		#migration main dir
		migrating_dir 	= Dir.pwd + "/db/migrations"
		empty_directory(migrating_dir) unless File.exist?(migrating_dir)

		#migration module sub dir
		module_current	= options[:to] || get_default_module
		mpath 			= migrating_dir + "/#{module_current}"

		#get the data schema from file
		#get the data schema from db

		#compate the data schema, if different, create the migration file
		is_different = false

		#create a migration record
 		if is_different
			empty_directory(mpath) unless File.directory?(mpath)

			auto		= options.autocomplete? ? true : false
			data 		= db.arrange_fields(argv, auto)
 			file_nums 	= get_file_num(mpath)
			file 		= mpath + "/#{file_nums}_#{data[:operator]}_#{data[:table]}.rb"

			if db.get_tables.include? data[:table].to_sym
				isay "\nNote that the table #{data[:table]} is existing, it hasn't created .\n"
			else
				content = db.generate_migration data
				isay "\n" + "#"*15 + " your migration content as the following " + "#"*15 + "\n"
 				isay content
 				create_file file, content
			end
		end

		#implement the migrations
		if options.run? 
			error("No schema at #{path}") unless File.exist?(migrating_dir)
			unless Dir[migrating_dir + "/*"].empty?
				db.run migrating_dir, :table => :schema_info, :column => module_current.to_sym
			else
				error "No migration files at #{path}"
			end
			isay "Implementing complete"
		end

		#dump the database schema to a mrgration file
		if options[:dump] != nil
			dump = options[:dump] == 'D' ? '-D' : '-d'
			run("sequel #{dump} #{dbcont} > #{gpath}/#{time}.rb")
		end

		#output the schema/migration
		if options.output?
			isay "The current adapter of database is #{db.get_scheme}."
			isay "The details of schema as the following."
			puts "\n"

			#puts the tables of database to array of hash
			if options.details?
				print db.dump_schema_migration
			else
				db.get_tables.each do |table|
					print table.to_s.ljust(20, ' ')
					print db.get_columns(table)
					print "\n"
				end
			end
			puts "\n"
		end
	end

end
