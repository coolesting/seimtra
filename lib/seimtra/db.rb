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

	## 
	# autocomplete field of database
	#
	# name string, 	the table name
	# argv array, 	the fields
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
	#
	# arrange the field with the way of Sequel migration format
	# ['table_name', 'field1', 'field2', 'field3']
	# ['table_name', 'field1:primary_id', 'field2:string', 'field3:string:null=false']
	# ['rename', 'old_table', 'new_table]
	# ['drop', 'field1', 'field2', 'field3']
	# ['alter', 'table_name', 'field1', 'field2', 'field3']
	#
	# == returned value
	#
	# it is a hash value, the key as the following
	# :operator, symbol ---- create, alter, drop, rename
	# :table, 	string 	---- table name
	# :fields	array 	---- 

	def arrange_fields data
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

		#fields and field types
		res[:fields] = []
		res[:types] = {}
		if data.length > 0
			data.each do | item |
				if item.include?(":")
					arr = item.split(":")
					res[:fields] << arr[0]
					res[:types][arr[0]] = arr[1]
				else
					res[:fields] << item
				end
			end
		end

		res
	end

	def generate_migration data
		operator 	= data[:operator]
		table		= data[:table]
		fields		= data[:fields]

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
				content << "\t\t\tcolumn :"
				if item.index(":")
 					content << item.gsub(/=/, " => ").gsub(/:/, ", :")
				else
					content << "#{item}, String"
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


class Seimtra_system < Db

	#a db extension for several business application

	def check_module module_names

		#get all of module, if no verifying module for installing
		install_modules = []
		local_modules	= []
		db_modules		= []

		Dir["modules/*/#{Sbase::Files[:info]}"].each do | item |
			local_modules << item.split("/")[1]
		end

		if select(:modules)
			select(:modules).all.each do | row |
				db_modules << row[:module_name] unless row[:module_name] == "" or row[:module_name] == nil
			end
		end

		install_modules = module_names.empty? ? local_modules : module_names

		db_modules.each do | item |
			install_modules.delete item if install_modules.include? item
		end

		if install_modules.empty?
			@error 	= true
			@msg	= "No module to be installed."
		else
			install_modules
		end
	end

	def add_module install_modules

		install_modules.each do | name |
			path = Dir.pwd + "/modules/#{name}/" + Sbase::Files[:info]
			result = SCFG.load :path => path , :return => true
			unless result.empty?
				module_info_item = Sbase::Module_info.keys
				options = {}
				result.each do | item |
					key, val = item
					options[key.to_sym] = val if module_info_item.include? key.to_sym
				end
				insert :modules, options
			end
		end

		#scan installing files to database
		install_modules.each do | name |
			add_setting name
			add_panel name
			add_block name	
		end

	end

	def add_setting name

		mid 	= DB[:modules].filter(:module_name => name).get(:mid)
		path 	= Dir.pwd + "/modules/#{name}/" + Sbase::File_install[:setting]
		result 	= SCFG.load :path => path , :return => true

		unless result.empty?
			result.each do | item |
				key, val = item
				unless DB[:setting].filter(:skey => key, :mid => mid).get(:skey)
					insert :setting, :skey => key, :sval => val, :mid => mid, :changed => Time.now
				end
			end
		end	

	end

	def add_panel name

		mid 	= DB[:modules].filter(:module_name => name).get(:mid)
		path	= Dir.pwd + "/modules/#{name}/" + Sbase::File_install[:panel]
		result 	= SCFG.load :path => path , :return => true

 		unless result.empty?
			table_fields = DB[:panel].columns!

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
				options[:mid] = mid unless options.include? :mid

				unless DB[:panel].filter(:name => options[:name], :mid => mid).get(:name)
 					insert :panel, options
				end
			end
		end

	end

	def add_block name

		mid 	= DB[:modules].filter(:module_name => name).get(:mid)
		path 	= Dir.pwd + "/modules/#{name}/" + Sbase::File_install[:block]
		result	= SCFG.load :path => path , :return => true

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
