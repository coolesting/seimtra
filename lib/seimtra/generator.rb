require 'erb'	
class Generator

	attr_accessor :contents

	def initialize module_name = 'custom'

		@contents 		= {}
		@load_apps 		= []
		@load_tpls 		= []
		@processes 		= []

		@path			= @name = ''
		@module_name	= module_name

		@style 			= [:table, :list]
		@enable			= [:edit, :new, :rm]
		@filter 		= [:index, :foreign_key, :unique]

		#A condition for deleting, updeting, editting the record
		@keyword 		= [:primary_key, :Integer, :index, :foreign_key, :unique]

		#temporary variable as the template variable
		@t				= {}

	end

	def run argv
	end

	def create_route argv, from_tpl = false
		set_path :routes
		if from_tpl == true
			argv.each do | name |
				@contents[@path] = get_erb_content name, :applications
			end
		else
			argv.each do | route |
				args = route.split ':'
				if args.length > 1
					meth = args.shift
					args.each do | name |
						@contents[@path] += "#{meth} '/#{@module_name}/#{name}' do \n"
						@contents[@path] += "end \n\n"
					end
				end
			end
		end
	end

	def create_table argv
	end

	private

		# generate the template file to project path that is the returned value
		def set_path name, type = :applications
			if type == :applications
				path = "modules/#{@module_name}/applications/#{name.to_s}_#{Time.now}.rb"
				@contents[path] = '' unless @contents.include? path
			else
				path = "modules/#{@module_name}/templates/#{@module_name}_#{name.to_s}.slim"
				@tpl_contents[path] = "" unless @tpl_contents.include? path
			end
			@path = path
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

		def get_erb_content name, type = :templates
			path = ROOTPATH + "/docs/scaffolds/#{type.to_s}/#{name.to_s}.tt"
			if File.exist? path
				content = File.read(path)
				t = ERB.new(content)
				t.result(binding)
			else
				"No such the file #{path}" 
			end
		end

end
