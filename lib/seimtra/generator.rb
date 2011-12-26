require 'erb'	
class Generator

	attr_accessor :template_contents, :app_contents

	def initialize(name, module_name = 'custom', options = {})

		@app_contents 	= {}
		@template_contents 	= {}

		@load_apps 		= []
		@load_tpls 		= []
		@processes 		= []

		@name 			= name
		@module_name	= module_name

		@style 			= [:table, :list]
		@enable			= [:edit, :new, :rm]
		@filter 		= [:index, :foreign_key, :unique]

		#A condition for deleting, updeting, editting the record
		@keyword 		= [:primary_key, :Integer, :index, :foreign_key, :unique]

		#template variable
		@tpl_var 		= {}
		#temporary variable
		@tmp_var		= {}

		#preprocess data
		unless options.empty?
			options.each do | key, val |
				if self.respond_to?("preprocess_#{key}", true)
					send("preprocess_#{key}", val) 
				end
			end
		end

		#process the action
		unless @processes.empty?
			@processes.each do | process |
				send("process_#{process}") if self.respond_to?("process_#{process}", true)
			end
		end
				
		#load the content of application
		unless @load_apps.empty?
			@load_apps.each do | app |
				name = grn
				@app_contents[name] = "" unless @app_contents.has_key? name
				@app_contents[name] += "# == created at #{Time.now} == \n"
				if self.respond_to?("load_app_#{app}", true)
					@app_contents[name] += send("load_app_#{app}") 
				else
					@app_contents[name] += get_erb_content(app, 'applications')
				end
				@app_contents[name] += "\n\n"
			end
		end

		#load the content of template
		unless @load_tpls.empty?
			@load_tpls.each do | tpl |
				send("load_template_#{tpl}")  if self.respond_to?("load_template_#{tpl}", true)
			end
		end

		puts @app_contents
 		puts @template_contents
	end

	private
		
		#================== preprocess data of option argument ==================

		def preprocess_routes(argv)
			unless argv.empty?
				@load_apps << "routes"
				@tmp_var[:routes] = argv
			end
		end

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
				argv.each do | item |
					@tmp_var[:enable] << item if @enable.include? item.to_sym
				end
			end
		end

		def preprocess_style(str)
			@tmp_var[:style] = str if @style.include? str.to_sym
		end

		def preprocess_view(argv)
			unless argv.empty?
				@processes << "view" 
				@tmp_var[:view] = argv
			end
		end

		#================== process the main program ==================
		
		def process_view
			@tmp_var[:style] = @style[0].to_s unless @tmp_var.has_key? :style
			@load_apps << 'view'
			@load_tpls << 'view'
		end

# 		def _process_data(with, argv)
# 			if argv.count > 0
# 				# For example,
# 				# primary_key:pid
# 				# Integer:aid
# 				# String:title
# 				# String:body
# 				argv.each do |item|
# 					key, val = item.split(":")
# 					unless @filter.include?(key)
# 						@argv[val] = key 
# 					end
# 					if @tpl_var[:keyword] == '' and @keyword.include?(key)
# 						@tpl_var[:keyword] = val.index(',') ? val.sub(/[,]/, '') : val
# 					end
# 				end
# 			end
# 
# 			@keyword = @fields[0] if @keyword == ''
# 		end

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

		# ========================= load content of tamplate =========================

		def load_app_routes
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

		def load_template_view
			@template_contents[gtn(@tmp_var[:style])] = get_erb_content(@tmp_var[:style])
		end

		def load_template_pager
			@template_contents[gtn(@tmp_var[:style])] += get_erb_content :pager
		end

		def load_template_search
			@template_contents[gtn(@tmp_var[:style])] = get_erb_content(:search) + @template_contents[gtn(@tmp_var[:style])]
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
			path = ROOTPATH + "/docs/scaffolds/#{type}/#{name.to_s}.tt"
			if File.exist? path
				content = File.read(path)
				t = ERB.new(content)
				t.result(binding)
			else
				"No such the file #{path}" 
			end
		end

end
