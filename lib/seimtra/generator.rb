require 'erb'	
class Generator

	attr_accessor :contents, :app_ext, :tpl_ext

	def initialize module_name = 'custom'
		
		#origin data
		@panels 		= {}

		#generate data
		@app_boxs 		= {}
		@tpl_boxs		= {}

		#output data
		@contents 		= {}

		@filenames		= {}
		@route_heads	= {}

		@module_name	= module_name
		@route_path		= "#{@module_name}"
		@app_ext		= '.rb'
		@tpl_ext		= '.slim'
		@app_name		= 'applications'
		@tpl_name		= 'templates'

		@operators 		= [:table, :list, :form, :route]
		@enables		= [:edit, :new, :rm]
		@filters		= [:index, :foreign_key, :unique]

		#a condition for deleting, updeting, editting the record
		@keywords 		= [:primary_key, :Integer, :index, :foreign_key, :unique]

		#A temporary variable to store the template variable
		@t				= {}

		#A point for how to identify the data in variables @panels, @boxs, @t
		@p 				= 0
	end

	def run argv
		return false unless argv.length > 1

		#by default, the first item will be realize as the route name
		name = ''
		unless @operators.include? argv[0].to_sym
			name = argv.shift
			@route_path += "/#{name}" 
		end

		#initialize the template panel
		flag = 0
		@panels[flag] = {}
		@panels[flag][:id] = flag
		@panels[flag][:data] = []
		@panels[flag][:operator] = 'default'

		#loop array for separating the operator and content of operator
		while argv.length > 0
			if @operators.include? argv[0].to_sym
				flag = flag + 1
				@panels[flag] = {}
				@panels[flag][:id] = flag
				@panels[flag][:data] = []
				@panels[flag][:operator] = argv.shift 
			end
			@panels[flag][:data] << argv.shift
		end

		flag += 1

		return false unless flag > 1

		#process the data
		flag.times do | i |
			if respond_to?("process_#{@panels[i][:operator]}", true)
				@p = i
				send "process_#{@panels[i][:operator]}"
			end
		end

		#generate the contents, then push to a boxs
		flag.times do | i |
			if @panels[i].include? :loads
				@panels[i][:loads].each do | panel |
					@p = i
					panel.index('.app') == nil ? g_tpl(panel) : g_app(panel)
				end
			end
		end

		#merge the content and generate the target files

	end

	##
	# == output
	# == arguments
	# num, Integer, one case of conditions
	def output num
		case num
		when 1 
			@panels
		when 2
			@boxs
		when 3 
			@t
		else
			@contents
		end
	end

	private

		## 
		# == get_path
		# generate the target file path 
		#
		# == arguments
		# type, String, the string value is templates, or applications
		# name, String, the file name
		#
		def get_path type, name = ''
			ext = type == @tpl_name ? @tpl_ext : @app_ext
			name = name == '' ? @module_name : (@module_name + '_' + name)
			path = "modules/#{@module_name}/#{type}/#{name}#{ext}"
			@filenames[path] = [] unless @filenames.include? path
			path
		end

		## 
		# == get_erb_content
		# get the ERB template content and parse the it
		#
		# == arguments
		# name, String, the name of template in the one of docs/templates/*
		def get_erb_content name
			path = ROOTPATH + "/docs/templates/#{name}"
			if File.exist? path
				content = File.read(path)
				t = ERB.new(content)
				t.result(binding)
			else
				"No such the file #{path}" 
			end
		end

		##
		# == init_tpl_vars 
		# initialize template variables
		#
		# @t[:name], the module name
		# @t[:route_meth], a method head, likes the 'get', 'post'
		# @t[:route_path], a route path, likes 'login', 'register'
		# @t[:select_sql], a select query
		# @t[:insert_sql], a insert query
		# @t[:delete_by], a delete query
		# @t[:update_by], a update query
		# @t[:update_sql], a update query
		# @t[:tpl_name], a template name that should be has a prefix with the module name 
		# @t[:vars], a pure text variable that containss sub-variable below
		# @t[:vars][:title], the default page title
		def init_tpl_vars
			@t[:name] 			= @module_name
			@t[:route_meth] 	= 'get'
			@t[:route_path] 	= @route_path

			@t[:vars] = {}
			@t[:vars][:title] 	= @module_name
		end

		##
		# == g_app
		# generate the application
		#
		# == arguments
		# name, String, the case of conditions
		def g_app name
			#push the route head to Array
			route_head = "get '/#{name}' do\n"
			@route_heads[route_head] = [] unless @route_heads.include? route_head
			@route_heads[route_head] << @p

			#push the contents to box
			@app_boxs[@p][:contents] = name

			#set the filenames
			@filenames[get_path(@app_name)] << @p
		end

		##
		# == g_tpl
		# generate the template
		#
		# == arguments
		# name, String, the case of conditions
		def g_tpl name
			@tpl_boxs[@p] = get_erb_content(name)
			@filenames[get_path(@tpl_name)] << @p
		end

		##
		# == create route
		def process_route
			@t[@p][:loads] = ['show.app']
		end

		##
		# == create table
		def process_table
			@t[@p][:loads] = ['table.tpl', 'show.app']
		end

		##
		# == create list
		def process_list
			@t[@p][:loads] = ['list.tpl', 'show.app']
		end

		##
		# == create form
		def process_form
			@t[@p][:loads] = ['form.tpl', 'form.app']
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
