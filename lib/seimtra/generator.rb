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
		@route_array	= {}

		@module_name	= module_name
		@route_path		= "#{@module_name}"
		@app_file_name	= 'rb'
		@tpl_file_name	= 'slim'
		@app_dir_name	= 'applications'
		@tpl_dir_name	= 'templates'

		@operators 		= [:table, :list, :form, :route]
		@filters		= [:index, :foreign_key, :unique]
		@route_head		= [:show, :edit, :new, :rm]
		@route_head.each do | route_head |
			@route_array[route_head] = []
		end

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
				@t[@p] = {} unless @t.include? @p
				send "process_#{@panels[i][:operator]}"
			end
		end

		#generate the contents, then push to a boxs
		flag.times do | i |
			if @panels[i].include? :loads
				@panels[i][:loads].each do | panel |
					@p = i
					panel.class.to_s == 'String' ? create_tpl(panel) : create_app(panel)
				end
			end
		end

		#merge application contents
		path = get_target_path(@app_dir_name)
		@route_head.each do | route |
			@contents[path] = send("merge_#{route.to_s}", @route_array[route])
		end

		#merge template contents
		@filenames.each do | path, points |
			@contents[path] = '' unless @contents.include? path
			points.each do | p |
				@contents[path] += @tpl_boxs[p]
			end
		end
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
			@app_boxs.merge @tpl_boxs
		when 3 
			@t
		else
			@contents
		end
	end

	private

		## 
		# == get_target_path
		# generate the target file path 
		#
		# == arguments
		# type, String, the string value is templates, or applications
		# name, String, the file name
		#
		def get_target_path type, name = ''
			ext = type == @tpl_dir_name ? @tpl_file_name : @app_file_name
			name = name == '' ? @module_name : (@module_name + '_' + name)
			path = "modules/#{@module_name}/#{type}/#{name}.#{ext}"
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
		# == create_app
		# generate the application
		#
		# == arguments
		# name, String, the case of conditions
		def create_app name
			#process the data
			[:vars, :page, :text, :sql, :tpl, :redirect].each do | event |
				if @t[@p].include? event
					@app_boxs[@p] = '' unless @app_boxs.include? @p
					send("g_#{event.to_s}") 
				end
			end

			#push the route head to array
			@route_array[name] << @p
		end

		##
		# == create_tpl
		# generate the template
		#
		# == arguments
		# name, String, the case of conditions
		def create_tpl name
			@tpl_boxs[@p] = '' unless @tpl_boxs.include? @p
			@tpl_boxs[@p] += get_erb_content(name)

			#set the filenames
			path = get_target_path(@tpl_dir_name)
			@filenames[path] << @p
		end

		##
		# == create route
		def process_route
			@t[@p][:loads] = [:show]
		end

		##
		# == create table
		def process_table
			@t[@p][:loads] = ['table.tpl', :show]
		end

		##
		# == create list
		def process_list
			@t[@p][:loads] = ['list.tpl', :show]
		end

		##
		# == g_vars
		def g_vars
			@t[@p][:vars].each do | key,val |
				@app_boxs[@p] += "\t@#{key} = #{val}\n"
			end
		end

		##
		# == g_page
		def g_page
			'page'
		end

		##
		# == g_text
		def g_text
			@app_boxs[@p] += "\t#{@t[@p][:text]}\n"
		end

		##
		# == g_sql
		def g_sql
			@app_boxs[@p] += "\t#{@t[@p][:sql]}\n"
		end

		##
		# == g_tpl
		def g_tpl
			@app_boxs[@p] += "\t#{@tpl_file_name} :#{@t[@p][:tpl]}\n"
		end

		##
		# == g_redirect
		def g_redirect
			@app_boxs[@p] += "\tredirect #{@t[@p][:redirect]}\n"
		end

		##
		# == merge_show
		def merge_show points
			content = "get '/show' do \n"
			points.each do | p |
				content += @app_boxs[p]
			end
			content += "end\n"
			content
		end

		##
		# == merge_new
		def merge_new
		end

		##
		# == merge_edit
		def merge_edit
		end

		##
		# == merge_rm
		def merge_rm
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

end
