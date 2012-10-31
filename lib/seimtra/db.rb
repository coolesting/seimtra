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
		columns.include?(name) ? true : false
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
	# ['table_name', 'field1:primary_id', 'field2:string', 'field3:assoc=table.field_name']
	# ['table_name', 'field1:primary_id', 'field2:string', 'field3:assoc=table.field_name:html=select']
	# ['rename', 'old_table', 'new_table]
	# ['drop', 'field1', 'field2', 'field3']
	# ['alter', 'table_name', 'field1', 'field2', 'field3']
	#
	# == Returned
	# it is a hash value, the options as the following
	# :operator, symbol ---- :create, :alter, :drop, :rename
	# :table, 	string 	---- table name
	# :fields,	array 	---- [field1, field2, field3]
	# :types,	hash	---- {field1 => type_name, field2 => type_name}
	# :htmls,	hash	---- {field1 => html_type, field2 => html_type}
	# :others,	hash	---- {field1 => {attr => val}, field2 => {attr1 => val1, attr2 => val2}}
	# :assoc,	hash	---- {field1 => [table, field1, assoc_field], field2 => [table, field2, assoc_field]}

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

		res[:htmls] 	= {}
		res[:types] 	= {}
		res[:fields] 	= []
		res[:others] 	= {}
		res[:assoc] 	= {}


		if data.length > 0

			#auto the fields
			data = autocomplete(res[:table], data) if auto == true
			data.each do | item |
				if item.include?(":")
					arr = item.split(":")

					#field name
					field = arr.shift
					res[:fields] << field

					#field type
					if Sbase::Field_type.include?(arr[0].to_sym) or Sbase::Main_key.include?(arr[0].to_sym)
						res[:types][field] = arr.shift
					else
						res[:types][field] = match_field_type field
					end

					res[:htmls][field] = res[:types][field]

					#other attributes and assoc table-field
					if arr.length > 0
						arr.each do | a |
							if a.include? "="
								key, val = a.split "="
								key = key.to_sym

								if key == :assoc
									#the assocciated attribute format as field:integer:assoc=table.field
									res[:assoc][field] = {} unless res[:assoc].include? field
									if val.include? "."
										table, assoc_field = val.split "."
										res[:assoc][field] = [table, field, assoc_field]
									end
									res[:htmls][field] = "select"
									res[:types][field] = "integer"
								elsif key == :html
									res[:htmls][field] = val
								else
									res[:others][field] = {} unless res[:others].include? field
									res[:others][field][key] = val
								end
								
							end
						end
					end
				else
					res[:fields] << item
					res[:htmls][item] = "string"
					res[:types][item] = match_field_type item
				end
			end
		end
		
		res
	end

	#judge the field type, automatically 
	def match_field_type field
		field = field.to_s
		len   = field.length
		if field[len-2] == 'i' and field[len-1] == 'd'
			'integer'
		else
			'string'
		end
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

		scfg = Sfile.read Dir.pwd + "/Seimfile"
		default_lang = scfg.include?(:lang) ? scfg[:lang] : 'en'

		#first of all, load the installation library
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

		#second, scan the file info of installation folder to database
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

			#scanning the language folder
			Dir["modules/#{name}/languages/#{default_lang}.lang"].each do | file |
				lang_type 	= file.split("/").last.split(".").first
				result 		= Sfile.read file
				mid			= DB[:module].filter(:name => name).get(:mid)

 				result.each do | label, content |
					fields = {:label => label.to_s, :mid => mid}
					if DB[:language].filter(fields).count == 0
						fields[:content] = content
 						DB[:language].insert(fields)
					else
						DB[:language].filter(fields).update(:content => content)
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

end
