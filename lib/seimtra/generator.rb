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
		contents[flag] 	= ["get;#{@module_name}"]
		unless @operators.include? argv[0].to_sym
			contents[flag][0] = contents[flag][0] + "/#{argv.shift}"
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

		operators.each do | id, name |
			send("create_#{name}", contents[id]) if respond_to? "create_#{name}"
		end
	end

	##
	# @arguments => ['get;login'] or ['get;login', 'post;login/:id']
	def create_route argv
		path = get_path
		argv.each do | arg |
			@t[:route_meth] , @t[:route_path] = arg.split ';'
			@contents[path] = get_erb_content :route
		end
	end

	def create_table argv
		p 'table'
	end

	def create_list argv
		p 'list'
	end

	def create_form argv
		p 'form'
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

		# generate the template file to project path that is the returned value
		def get_path argv = {}
			type = argv.include?(:type) ? argv[:type] : 'applications'
			name = argv.include?(:name) ? (@module_name + '_' + argv[:name]) : @module_name
			name = type == "applications" ? (name + @app_ext) : (name + @tpl_ext)
			path = "modules/#{@module_name}/#{type}/#{name}"
		end
		
		#The order of processing program
		#Step 1
		#================== preprocessing for data of options ==================

		def preprocess_form(argv)
		end

		def preprocess_routes(argv)
			@load_apps << "routes"
			@t[:routes] = argv
		end

		def preprocess_with(hash)
			hash.each do | key, val |
				@t[key.to_sym] = val unless @t.has_key? key.to_sym
			end
		end

		def preprocess_enable(argv)
			@t[:enable] = []
			argv.each do | item |
				@t[:enable] << item if @enable.include? item.to_sym
			end
		end

		def preprocess_view(argv)
			@processes << "view" 
			@t[:fields] = argv
			@t[:table] = @name unless @t.has_key? :table
			@t[:select_sql] = "SELECT #{@t[:fields].join(' ')} FROM #{@t[:table]}"
		end

		#Step 2
		#================== processing for the main program ==================
		
		def process_view
			@load_apps << 'view'
			@load_tpls << 'view'
			@t[:style] = @style[0].to_s unless @t.has_key? :style
			@t[:style] = @style[0].to_s unless @style.include? @t[:style]

			#process enable
			
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

		def load_template_view
			@tpl_contents[gtn(@t[:style])] = get_erb_content(@t[:style])
		end

		def load_template_pager
			@tpl_contents[gtn(@t[:style])] += get_erb_content :pager
		end

		def load_template_search
			@tpl_contents[gtn(@t[:style])] = get_erb_content(:search) + @tpl_contents[gtn(@t[:style])]
		end

		def get_erb_content name
			path = ROOTPATH + "/docs/templates/#{name.to_s}.tt"
			if File.exist? path
				content = File.read(path)
				t = ERB.new(content)
				t.result(binding)
			else
				"No such the file #{path}" 
			end
		end

end
