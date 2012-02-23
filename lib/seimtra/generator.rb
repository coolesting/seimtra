require 'erb'	
class Generator

	attr_accessor :contents, :app_ext, :tpl_ext

	def initialize module_name = 'custom'

		@contents 		= {}
		@load_apps 		= []
		@load_tpls 		= []
		@processes 		= []

		@module_name	= module_name
		@route_path		= "#{@module_name}"
		@app_ext		= '.rb'
		@tpl_ext		= '.slim'

		@operators 		= [:table, :list, :form, :route]
		@enables		= [:edit, :new, :rm]
		@filters		= [:index, :foreign_key, :unique]

		#a condition for deleting, updeting, editting the record
		@keywords 		= [:primary_key, :Integer, :index, :foreign_key, :unique]

		#temporary variable to store the template variable
		@t				= {}

		#a test variable to show this data
		@test			= {}

	end

	def run argv
		operators	= {}
		contents	= {}
		flag		= 1

		return false unless argv.length > 1

		operators[flag] = 'route'

		#set the default route name
		unless @operators.include? argv[0].to_sym
			@route_path = @route_path + "/#{argv.shift}"
		end

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

		operators.shift
		operators.each do | id, name |
			send("process_#{name}", contents[id])  if respond_to?("process_#{name}", true)
			@t = {}
		end
	end

	##
	# == output
	# == arguments
	# num, Integer, one case of situation in condition
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
		# == set_path
		# generate the file path that will be use later
		#
		# == arguments
		# type, String, the value is templates, or applications
		# name, String, the file name
		#
		def set_path type, name
			name = name == '' ? @module_name : (@module_name + '_' + name)
			name = type == "applications" ? (name + @app_ext) : (name + @tpl_ext)
			@path = "modules/#{@module_name}/#{type}/#{name}"
			@contents[@path] = '' unless @contents.has_key? @path 
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
		# == load_content
		# load the template content to file with real path
		#
		# == arguments
		# tpl_path, String, the template path in docs/templates
		# target_path, String, the file path that needs to be wirte the content
		def load_content tpl_path, target_path = ''
			type = tpl_path.index('.tpl') != nil ? 'templates' : 'applications'
			set_path type, target_path
			@contents[@path] = @contents[@path] + get_erb_content(tpl_path)
		end

		##
		# == create route
		# == arguments
		# argv, Array, 'get;login'
		def process_route argv
			load_content 'show.app'
		end

		##
		# == create table
		# == arguments
		# argv, Array, ['name:pawd:email']
		def process_table argv
			load_content 'table.tpl', 'show'
		end

		##
		# == create list
		# == arguments
		# argv, Array, ['name:pawd:email']
		def process_list argv
			load_content 'list.tpl', 'show'
		end

		##
		# == create form
		# == arguments
		# argv, Array, ['text:name', 'pawd:pawd']
		def process_form argv
			load_content 'form.tpl', 'show'
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
