class Db

	# A interface class for Sequel ORM

	attr_accessor :msg, :error

	def initialize path = './environment.rb'
		@msg 	= ''
		@error 	= false
		epath 	= File.expand_path(path)
		if File.exist?(epath)
			require epath
		else
			@error 	= true
			@msg	= 'No such the file ' + epath
		end
	end

	#@name symbol
	def check_column name
		columns = get_columns
		columns.include?(name.to_sym) ? true : false
	end

	def get_tables
		DB.tables
	end

	def get_scheme
		DB.class.adapter_scheme.to_s
	end

	def get_schema table
		DB.schema table
	end

	##
	# table, string
	def get_columns table = nil
		if table == nil
			argv = []
			get_tables.each do | table |
				argv += DB[table.to_sym].columns!
			end
			argv
		else
			DB[table.to_sym].columns!
		end
	end

	def dump_schema table
		Sequel.extension :schema_dumper
		DB.dump_table_schema(table)
	end

	def dump_schema_migration
		Sequel.extension :schema_dumper
		DB.dump_schema_migration
	end

	def run path, argv = {}
		Sequel.extension :migration
		Sequel::Migrator.run DB, path, argv
	end

	def insert table, options = {}
		unless options.empty?
			DB[table].insert(options)
		end
	end

	def select table
		DB.tables.include?(table) ? DB[table.to_sym] : nil
	end

	# == autocomplete
	# autocomplete field of database
	# 
	# == input
	# @name string, the table name
	# @argv array, 	the fields
	#
	# == output
	# an array, like this ['aid:primary_key', 'title', 'body', 'created:datetime', 'changed:datetime']
	def autocomplete name, argv
		#match a id
		i = 1
		while i > 0 
			id 	= name[0, i] + 'id'
			i 	= check_column(id.to_sym) ? (i + 1) : 0
		end
		argv.unshift("#{id}:primary_key")

		#match time field
		argv << 'created:datetime'
		argv << 'changed:datetime'
		argv
	end

	# == arrange_fields
	# arrange the fields with specifying format
	# 
	# == Arguments
	# @data array, the details as following
	# @auto boolen, 
	#
	# ['table_name', 'field1', 'field2', 'field3']
	# ['table_name', 'field1:primary_id', 'field2:string', 'field3:string:null=false']
	# ['rename', 'old_table', 'new_table]
	# ['drop', 'field1', 'field2', 'field3']
	# ['alter', 'table_name', 'field1', 'field2', 'field3']
	#
	# == Returned
	# it is a hash value, the options as the following
	# :operator, symbol ---- :create, :alter, :drop, :rename
	# :table, 	string 	---- table name
	# :fields	array 	---- [field1, field2, field3]
	# :types,	hash	---- {field1 => type_name, field2 => type_name}
	# :others,	hash	---- {field1 => {attr => val}, field2 => {attr1 => val1, attr2 => val2}}
	# :assocc,	hash	---- {field1 => [table, field1, assocc_field], field2 => [table, field2, assocc_field]}

	def arrange_fields data, auto = false
		res = {}

		#operator
		operators = [:alter, :rename, :drop]
		res[:operator] = operators.include?(data[0].to_sym) ? data.shift.to_sym : :create

		#table
		if res[:table] == :rename or res[:table] == :drop
			res[:table] = data.join "_"
		else
			res[:table] = data.shift
		end

		res[:fields] = []
		res[:types] = {}
		res[:others] = {}
		res[:assocc] = {}

		if data.length > 0
			#auto the fields
			data = autocomplete(res[:table], data) if auto == true
			data.each do | item |
				if item.include?(":")
					arr = item.split(":")
					field = arr.shift
					res[:fields] << field
					res[:types][field] = arr.shift

					#other attributes and assocc table-field
					if arr.length > 0
						arr.each do | a |
							if a.include? "="
								key, val = a.split "="
								key = key.to_sym
								if key == :assocc
									#the assocc attribute format as assocc=table-assocc_field
									res[:assocc][field] = {} unless res[:assocc].include? field
									if val.include? "-"
										table, assocc_field = val.split "-"
										res[:assocc][field] = [table, field, assocc_field]
									end
								else
									res[:others][field] = {} unless res[:others].include? field
									res[:others][field][key] = val
								end
							end
						end
					end
				else
					res[:fields] << item
					res[:types][item] = "string"
				end
			end
		end

		res
	end

	def generate_migration data
		main_key	= Sbase::Main_key
		operator 	= data[:operator]
		table		= data[:table]
		fields		= data[:fields]
		types		= data[:types]

		content = "Sequel.migration do\n"
		content << "\tchange do\n"

		if operator == :drop or operator == :rename
			content << "\t\t#{operator}_table "
			i = 0
			fields.each do | f |
				content << ", " if i > 0
				content << ":#{f}"
				i = i + 1
			end
			content << "\n"

		elsif operator == :create
			content << "\t\t#{operator}_table(:#{table}) do\n"
			fields.each do | item |
				content << "\t\t\t"
				if main_key.include? types[item].to_sym
					content << "#{types[item]} :#{item}"
				else
					content << "#{types[item].capitalize} :#{item}"
				end
				content << "\n"
			end
			content << "\t\tend\n"

		elsif operator == :alter
			content << "\t\t#{operator}_table(:#{table}) do\n"
			content << "\t\t\t#{fields.shift} :"
			content << fields.join(", :")
			content << "\n"
			content << "\t\tend\n"
		end

		content << "\tend\n"
		content << "end\n"
		content
	end

end

#a db extension for several business methods
class Seimtra_system < Db

	# == check_module
	# check the local file module whether existing in db
	#
	# == output
	# return the local module that has not been installed to database, otherwise is null 
	def check_module module_names

		#get all of module if nothing be specified to installing
		install_modules = []
		local_modules	= []
		db_modules		= []

		Dir["modules/*/#{Sbase::Files[:info]}"].each do | item |
			local_modules << item.split("/")[1]
		end

		if select(:module)
			select(:module).all.each do | row |
				db_modules << row[:name] unless row[:name] == "" or row[:name] == nil
			end
		end

		install_modules = module_names.empty? ? local_modules : module_names

		return_modules = []
		db_modules.each do | item |
			return_modules << item unless install_modules.include? item
		end

		return_modules = local_modules if db_modules.empty?

		return_modules.empty? ? nil : return_modules

	end

	def add_module install_modules
		
		#first of all, load the installed library
		modules = get_module
		unless install_modules.class.to_s == "Array"
			arr = []
			arr << install_modules
			install_modules = arr
		end
		install_modules.each do | m |
			modules << m unless modules.include? m
		end

		modules.each do | name |
			path = Dir.pwd + "/modules/#{name}/install/install.rb"
			if File.exist? path
				require path 
			end
		end

		#second, scan the file info in the install folder to database
		install_modules.each do | name |
			Dir["modules/#{name}/install/*.sfile"].each do | file |
				file_name	= file.split("/").last
				table 		= file_name.split(".").first
				result 		= Sfile.read file

				#insert data
				unless result == nil
					if result.class.to_s == "Hash"
						arr = []
						arr << result
						result = arr
					end

					result.each do | row |
						if Seimtra_system.public_method_defined? "preprocess_#{table}".to_sym
							eval "row = preprocess_#{table}(#{row})"
						end

						write_to_db table, row
					end
				end
			end
		end

	end

	# == write_to_db
	# write a file to db with row by row
	#
	# == Arguments
	# table, string, a table name
	# result, hash, table field data
	def write_to_db table, row

		table			= table.to_sym
		table_fields 	= DB[table].columns!

		fields = {}
		if row.class.to_s == "Hash"
			row.each do | key, val |
				if table_fields.include? key.to_sym
					fields[key.to_sym] = val
				end
			end

			return if fields.empty?

			#do not insert if the data is exsiting
			#delete the time
			fields.delete :created if fields.include? :created
			fields.delete :changed if fields.include? :changed
			if DB[table].filter(fields).count == 0
 				fields[:changed] = Time.now if table_fields.include? :changed 
 				fields[:created] = Time.now if table_fields.include? :created 
 				insert table, fields
			end
		end

	end

	# == get_module
	# get all of modules that have been installed to database
	def get_module

		modules = []
		DB[:module].each do | row |
			modules << row[:name]
		end
		modules

	end

	def add_block name

		mid 	= DB[:modules].filter(:name => name).get(:mid)
		path 	= Dir.pwd + "/modules/#{name}/" + Sbase::File_install[:block]
		result	= Sfile.read path

 		unless result.empty?
			table_fields = DB[:block].columns!

			data_arr = []
			if result.class.to_s == "Hash"
				data_arr << result
			else
				data_arr = result
			end

			data_arr.each do | line |
				options = {}
				line.each do | item |
					key, val = item	
					options[key.to_sym] = val if table_fields.include? key.to_sym
				end
				options[:mid] = mid
					
				#set the default value for some fields of table
				default_num_id = 0
				Sbase::Block.keys.each do | item |
					if options.include? item
						index_id = Sbase::Block[item].index(options[item])
						options[item] = index_id == nil ? default_num_id : index_id
					else
						options[item] = default_num_id
					end
				end

				unless DB[:block].filter(:name => options[:name], :mid => mid).get(:name)
 					insert :block, options
				end
			end

		end

	end

end
