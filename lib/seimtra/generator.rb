require 'erb'	
class Generator

	attr_accessor :template_contents, :app_contents

	def initialize(name, module_name = :custom, options = {})

		@app_contents 	= {}
		@template_contents 	= {}

		@name 			= name
		@module_name	= module_name

		@actions 		= []
		@style 			= [:table, :list]
		@enable			= [:edit, :new, :rm]
		@filter 		= [:index, :foreign_key, :unique]

		#A condition for deleting, updeting, editting the record
		@keyword 		= [:primary_key, :Integer, :index, :foreign_key, :unique]

		#template variable
		@tpl_var 		= {}
		#temporary variable
		@tmp_var		= {}

		#options, an array of hash
		unless options.empty?
			options.each do | key, val |
				if self.respond_to?("preprocess_#{key}", true)
					send("preprocess_#{key}", val) 
				end
			end
		end
		puts options

		#_process_data(with, migration)
		unless @actions.empty?
			#preprocess data
			@actions.each do |action|
				send("process_data_#{action}") if self.respond_to?("process_data_#{action}", true)
			end

			@actions.each do |action|
				#process application
				name = grn
				@app_contents[name] = "" unless @app_contents.has_key? name
				@app_contents[name] += "# == create at #{Time.now} == \n"
				if self.respond_to?("process_app_#{action}", true)
					@app_contents[name] += send("process_app_#{action}") 
				else
					@app_contents[name] += get_erb_content(action, 'applications')
				end
				@app_contents[name] += "\n\n"

				#process template
				if self.respond_to?("process_template_#{action}", true)
					send("process_template_#{action}") 
				else
					@template_contents[gtn(action)] = get_erb_content(action)
				end
			end
		end

		puts @app_contents
		puts @template_contents
	end

	private

		def preprocess_with(hash)
			unless hash.empty?
				hash.each do | key, val |
					@tmp_var[key.to_sym] = val
				end
			end
		end

		def preprocess_enable(argv)
			unless argv.empty?
				@tmp_var[:enable] = []
				argv.each do | itme |
					@tmp_var[:enable] << itme if @enable.include? item.to_sym
				end
			end
		end

		def preprocess_style(str)
			@tmp_var[:style] = str if @style.include? str.to_sym
		end

		def preprocess_view(argv)
			unless argv.empty?
				@actions << "view"
				@tmp_var[:style] = @style[0].to_s unless @tmp_var.has_key? :style
			end
		end

		def preprocess_routes(argv)
			unless argv.empty?
				@actions << "routes"
				@tmp_var[:routes] = argv
			end
		end

		def process_app_routes
			if @tmp_var.has_key? :routes
				content = ''
				@tmp_var[:routes].each do | item |
					meth, route = item.split(':')
					content += "#{meth} '/#{@module_name}/#{route}' do \n"
					content += "end \n"
				end
			end
			content
		end

		def _process_data(with, argv)
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
					if @tpl_var[:keyword] == '' and @keyword.include?(key)
						@tpl_var[:keyword] = val.index(',') ? val.sub(/[,]/, '') : val
					end
				end
			end

			@keyword = @fields[0] if @keyword == ''
		end

		def process_data_new
			@tpl_var[:insert_sql] = insert_sql = ''
			@fields.each do |item|
				insert_sql += ":#{item} => params[:#{item}],"
			end
			@tpl_var[:insert_sql] = insert_sql.chomp(',')
		end

		def process_data_rm
			@tpl_var[:delete_by] = @keyword unless @tpl_var.include? :delete_by
		end

		def process_data_edit
			@tpl_var[:update_sql] = ''
			@tpl_var[:update_by] = @keyword unless @t.include? :update_by
		end

		def process_data_view
			@view = @with[:mode] if @with.include?(:mode) and @mode.include?(@with[:mode])
		end

		def process_template_view
			@template_contents[gtn(@view)] = get_erb_content(@view)
		end

		def process_template_pager
			@template_contents[gtn(@view)] += get_erb_content :pager
		end

		def process_template_search
			@template_contents[gtn(@view)] = get_erb_content(:search) + @template_contents[gtn(@view)]
		end

		#get the path of appliction as the name
		def grn(file = "routes")
			"modules/#{@module_name}/applications/#{file}.rb"
		end

		#get the path of template as the name
		def gtn(name)
			"modules/#{@module_name}/templates/#{@name}_#{name}.slim"
		end

		def get_erb_content(name, type = 'templates')
			path = ROOTPATH + "/docs/scaffolds/#{type}/#{name}.tt"
			if File.exist? path
				content = File.read(path)
				t = ERB.new(content)
				t.result(binding)
			else
				"No such the file #{path}" 
			end
		end

end
