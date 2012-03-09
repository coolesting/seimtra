require 'erb'	
class Generator

	attr_accessor :contents, :app_ext, :tpl_ext

	def initialize module_name = 'custom'
		
		#origin data
		@panels 		= {}

		#the templates we need to load
		@tpls			= {}

		#output data
		@contents 		= {}

		@module_name	= module_name
		@route_path		= @module_name
		@app_file_name	= 'rb'
		@tpl_file_name	= 'slim'
		@app_dir_name	= 'applications'
		@tpl_dir_name	= 'templates'

		@operators 		= [:table, :list, :form, :route]
		@filters		= [:index, :foreign_key, :unique]
		@route_head		= [:show, :edit, :new, :rm]
		@flowitmes		= [:vars, :text, :page, :sql, :tpl, :redirect]

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
			@route_path = "#{name}" 
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

		#generate template contents
		if @tpls
			@tpls.each do | tpl_name, tpls |
				path = get_target_path(@tpl_dir_name, tpl_name)
				tpls.each do | tpl |
					@contents[path] += get_erb_content(tpl)
				end
			end
		end

		#generate application contents
		path = get_target_path(@app_dir_name)
		@t.each do | route_head, data |
			@data = data
			@contents[path] += "#{route_head}\n"
			@flowitmes.each do | itme |
				@contents[path] += send("g_#{itme.to_s}") if data.include? itme
			end	
			@contents[path] += "end\n\n"
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
		def get_target_path type, name = @module_name
			ext = type == @tpl_dir_name ? @tpl_file_name : @app_file_name
			path = "modules/#{@module_name}/#{type}/#{name}.#{ext}"
			@contents[path] = '' unless @contents.include? path
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

		def get_tpl_path name
			name = "#{@module_name}_#{name.to_s}"
			@tpls[name] = [] unless @tpls.include? name
			name
		end

		##
		# == get_route_head
		#
		# == arguments
		# meth, String, route method
		# type, String, the event, :show, :new, edit, :rm
		def get_route_head meth = 'get', type = :show
			route_head = "#{meth} '/#{type.to_s}/#{@route_path}' do"
			@t[route_head] = {} unless @t.include? route_head
			route_head
		end

		##
		# == process_route
		def process_route
			h = get_route_head
			init_tpl_data h, :vars, :page
		end

		##
		# == process_table
		def process_table
			tpl_name = get_tpl_path :show
			@tpls[tpl_name] << ['table.tpl']
		end

		##
		# == process_list
		def process_list
			@tpls[tpl_name] << ['list.tpl']
		end

		##
		# == init_tpl_vars 
		# initialize template variables
		#
		# @t[:vars], pure variables
		# @t[:page], page variables
		# @t[:select_sql], a select query
		# @t[:insert_sql], a insert query
		# @t[:delete_by], a delete query
		# @t[:update_by], a update query
		# @t[:update_sql], a update query
		# @t[:tpl_name], a template name that should be has a prefix with the module name 
		# @t[:vars], a pure text variable that containss sub-variable below
		# @t[:vars][:title], the default page title
		def init_tpl_data h, *argv
			if argv.include? :vars
				@t[h][:vars]			= {}
				@t[h][:vars][:title] 	= @route_path
			end
			
			if argv.include? :page
				@t[h][:page]			= {}
				@t[h][:page][:page_id]	= 1
				@t[h][:page][:page_size]= 10
			end
		end

		##
		# == g_vars
		def g_vars
			str = ''
			@data[:vars].each do | key,val |
				str += "\t@#{key.to_s} = '#{val}'\n"
			end
			str
		end

		##
		# == g_page
		def g_page
			arr = [
				"\t@page_id = #{@data[:page][:page_id]}\n",
				"\t@page_size = #{@data[:page][:page_size]}\n\n",
				"\t@page_id = params[:page_id] if params[:page_id] != nil",
				" and params[:page_id] > 0\n",
				"\t@page_offset = (@page_id.to_i - 1)*@page_size\n"
			]
			arr.join
		end

		##
		# == g_text
		def g_text
			"\t'#{@data[:text]}'\n"
		end

		##
		# == g_sql
		def g_sql
			@data[:sql]
		end

		##
		# == g_tpl
		def g_tpl
			"\t#{@tpl_file_name} :#{@data[:tpl_name]}\n"
		end

		##
		# == g_redirect
		def g_redirect
			"\tredirect '#{@data[:redirect]}\n'"
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
