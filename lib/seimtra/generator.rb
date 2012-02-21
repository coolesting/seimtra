require 'erb'	
class Generator

	attr_accessor :contents, :app_ext, :tpl_ext

	def initialize module_name = 'custom'

		@contents 		= {}
		@load_apps 		= []
		@load_tpls 		= []
		@processes 		= []

		@module_name	= module_name
		@app_ext		= '.rb'
		@tpl_ext		= '.slim'

		@operators 		= [:table, :list, :form, :route]
		@enables		= [:edit, :new, :rm]
		@filters		= [:index, :foreign_key, :unique]

		#a condition for deleting, updeting, editting the record
		@keywords 		= [:primary_key, :Integer, :index, :foreign_key, :unique]

		#temporary variable as the template variable
		@t				= {}

		#a test variable to show this data
		@test			= {}

	end

	def run argv
		operators	= {}
		contents	= {}
		flag		= 1

		#set the default route for the default page
		operators[flag]	= 'route' 
		contents[flag] 	= "get;#{@module_name}"
		unless @operators.include? argv[0].to_sym
			contents[flag] = contents[flag] + "/#{argv.shift}"
		end

		return false unless argv.length > 0

		#loop array for separating the operator and content of operator
		while argv.length > 0
			if @operators.include? argv[0].to_sym
				flag = flag + 1
				operators[flag]	= argv.shift 
				contents[flag]	= [] unless @contents.include? operators[flag]
			end
			contents[flag] << argv.shift
		end

		@test[:operator_content] = contents
		@test[:operator_id]		 = operators

		# preprocess data
		operators.each do | id, name |
			send("preprocess_#{name}", contents[id]) if respond_to?("preprocess_#{name}", true)
		end

		operators.each do | id, name |
			send "create_#{name}" 
		end
	end

	##
	# @arguments => ['get;login'] or ['get;login', 'post;login/:id']
	def create_route
		set_path :type => 'applications'
		@t[:routes].each do | arg |
			@t[:route_meth] , @t[:route_path] = arg.split ';'
			@contents[@path] = @contents[@path] + get_tpl(:route)
		end
	end

	def create_table
		set_path :type => 'templates', :name => 'show'
		@contents[@path] = @contents[@path] + get_tpl(:table)
	end

	def create_list
		set_path :type => 'templates', :name => 'show'
		@contents[@path] = @contents[@path] + get_tpl(:list)
	end

	def create_form
		set_path :type => 'templates', :name => 'new'
		@contents[@path] = @contents[@path] + get_tpl(:new)

		set_path :type => 'templates', :name => 'edit'
		@contents[@path] = @contents[@path] + get_tpl(:edit)
	end
	
	def output num
		case num
		when 1 
			@test[:operator_content]
		when 2 
			@test[:operator_id]
		when 3 
			@contents
		end
	end

	private

		##
		# generate the file path that will be use later
		# @argv => {:type => 'applications', :name => ''}
		#
		def set_path argv = {}
			type = argv.include?(:type) ? argv[:type] : 'applications'
			name = argv.include?(:name) ? (@module_name + '_' + argv[:name]) : @module_name
			name = type == "applications" ? (name + @app_ext) : (name + @tpl_ext)
			@path = "modules/#{@module_name}/#{type}/#{name}"
			@contents[@path] = '' unless @contents.has_key? @path 
		end

		## 
		# get the ERB template content and parse the it
		# @argv => :route, the name of template at path docs/templates/
		#
		def get_tpl name
			path = ROOTPATH + "/docs/templates/#{name.to_s}.tt"
			if File.exist? path
				content = File.read(path)
				t = ERB.new(content)
				t.result(binding)
			else
				"No such the file #{path}" 
			end
		end

		def preprocess_route argv
			@t[:routes] = [] unless @t.has_key? :routes
			@t[:routes] << argv if argv.class.to_s == "String"
			@t[:routes] += argv if argv.class.to_s == "Array"
		end

		def preprocess_table argv
		end
		
		def preprocess_list argv
		end

		def preprocess_form argv
 			preprocess_route ["get;#{@module_name}/new", "get;#{@module_name}/edit/:id", "post;#{@module_name}/edit/:id"]
		end

		def subprocess_data(with, argv)
			if argv.count > 0
				# For example,
				# primary_key:pid
				# Integer:aid
				# String:title
				# String:body
				argv.each do |item|
					key, val = item.split(":")
					unless @filter.include?(key)
						@argv[val] = key 
					end
					if @t[:keyword] == '' and @keyword.include?(key)
						@t[:keyword] = val.index(',') ? val.sub(/[,]/, '') : val
					end
				end
			end

			@keyword = @fields[0] if @keyword == ''
		end

		def subprocess_new
			@t[:insert_sql] = insert_sql = ''
			@fields.each do |item|
				insert_sql += ":#{item} => params[:#{item}],"
			end
			@t[:insert_sql] = insert_sql.chomp(',')
		end

		def subprocess_rm
			@t[:delete_by] = @keyword unless @t.include? :delete_by
		end

		def subprocess_edit
			@t[:update_sql] = ''
			@t[:update_by] = @keyword unless @t.include? :update_by
		end

		#Step 3
		#================== loading contents for tamplates ==================

		def load_app_routes
			if @t.has_key? :routes
				content = ''
				@t[:routes].each do | item |
					args = item.split(':')
					length = args.length - 1
					if length > 1
						length.times do | i |
							content += "#{args[0]} '/#{@module_name}/#{args[i+1]}' do \n"
							content += "end \n\n"
						end
					end
				end
			end
			content
		end

end
