class Generator

	attr_accessor :contents, :app_ext, :tpl_ext

	def initialize module_name = 'custom'
		
		#the templates we need to load
		@tpls			= {}

		#output data
		@contents 		= {}

		@route_heads	= {}

		@module_name	= module_name
		@route_path		= ''
		@app_file_name	= 'rb'
		@tpl_file_name	= 'slim'
		@app_dir_name	= 'applications'
		@tpl_dir_name	= 'templates'

		@operators 		= [:table, :list, :form, :route]
		@filters		= [:index, :foreign_key, :unique]
		@route_head		= [:show, :edit, :new, :rm]

		#a condition for deleting, updeting, editting the record
		@keywords 		= [:primary_key, :Integer, :index, :foreign_key, :unique]

		#store the template variables
		@t				= {}

		#origin data
		@panels 		= {}

		#a point for how to identify the data in variables @panels, @t
		@p 				= 0
	end

	def run argv
		return false unless argv.length > 1
		require 'seimtra/tpltpl'
		require 'seimtra/apptpl'

		#by default, the first item will be realize as the route name
		@route_path = "/#{argv.shift}" unless @operators.include? argv[0].to_sym

		@apptpl = Apptpl.new @tpl_file_name, @route_path

		#initialize data for the panel
		flag = 0
		@panels[flag] = {}
		@panels[flag][:id] = flag
		@panels[flag][:operator] = 'default'

		#process the operator and itme data
		while argv.length > 0
			if @operators.include? argv[0].to_sym
				flag = flag + 1
				@panels[flag] = {}
				@panels[flag][:id] = flag
				@panels[flag][:operator] = argv.shift 
			end
			@p = flag
			preprocess_item argv.shift 
		end

		flag += 1

		return false unless flag > 1

		#process the operator,
		#enable or disable some functions,
		#generate the route header,
		#load the template it needs.
		flag.times do | i |
			@p = i
			if respond_to?("process_#{@panels[@p][:operator]}", true)
				send "process_#{@panels[@p][:operator]}"
			end
		end

		#generate application contents
		path = get_target_path(@app_dir_name)
		@route_heads.each do | route_head, data |
			@contents[path] += "#{route_head}\n"
			@contents[path] += @apptpl.run(data)
			@contents[path] += "end\n\n"
		end

		#generate template contents
		@tpltpl = Tpltpl.new
		if @tpls
			@tpls.each do | tpl_name, tpls |
				path = get_target_path(@tpl_dir_name, tpl_name)
				tpls.each do | type |
					@contents[path] += @tpltpl.send("g_#{type.to_s}")
				end
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

		def get_tpl_name name = :show
			if @panels[@p].include? :tpl_name
				name = "#{@module_name}_#{@panels[@p][:tpl_name]}" 
			else
				name = "#{@module_name}_#{name.to_s}"
			end
			@tpls[name] = [] unless @tpls.include? name
			name
		end

		##
		# == init_tpl_vars 
		# initialize template variables
		#
		# the key of @route_heads[h]
		# :vars, pure variables
		# :page, page variables that includes the following vars
		# 		:page_id, the page id
		# 		:page_size, the page size
		# :select_sql, a select query
		# :insert_sql, a insert query
		# :delete_by], a delete query
		# :update_by], a update query
		# :update_sql, a update query
		# :tpl_name, a template name that should be has a prefix with the module name 
		# :vars, a pure basic variable that containss sub-variable as the following
		# 		:title, the default page title
		def init_tpl_data h, *argv
			if argv.include? :vars
				@route_heads[h][:vars]			= {}
				@route_heads[h][:vars][:title] 	= @route_path
			end
			
			if argv.include? :page
				@route_heads[h][:page]				= {}
				@route_heads[h][:page][:page_id]	= 1
				@route_heads[h][:page][:page_size]	= 10
			end
		end

		def process_route
			h = @apptpl.get_route_head
			init_tpl_data h, :vars, :page
		end

		def process_table
			tpl_name = get_tpl_name
			@tpls[tpl_name] << :table
		end

		def process_list
			tpl_name = get_tpl_name
			@tpls[tpl_name] << :list
		end

		def process_form
			tpl_name = get_tpl_name
			@tpls[tpl_name] << :form
		end

		def preprocess_item data
			if data.index(':')
				key, val = data.split(':') 
			else
				key = "fields"
				val = data
			end
			
			skey = key.to_sym
			case skey
			when :header, :fields, :enable, :disable, :source, :action, :method, :tpl_name
				if val.index(',')
					@panels[@p][skey] = val.split(',') 
				else
					@panels[@p][skey] = [val]
				end
			when :select_by, :delete_by
				@panels[@p][:sql][skey] = val
			when :page_id, :page_size
				@panels[@p][:page][skey] = val
			when :text, :select, :pawd, :button
				@panels[@p][:form][val] = key
			when :id, :class
				@panels[@p][:style][skey] = val
			end
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
