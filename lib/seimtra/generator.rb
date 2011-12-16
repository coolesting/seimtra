require 'erb'	
class Generator

	attr_accessor :template_contents, :app_contents

	def initialize(name, module_name = 'custom', fields = [], argv = {}, with = {}, level = 0)

		@app_contents 	= {}
		@with 			= {}
		@t 				= {}
		@template_contents 	= {}
		@argv 			= {}
		@name 			= name
		@module_name	= module_name
		@fields 		= fields
		@functions 		= @mode = []
		@mode 			= ['table', 'list']
		@level 			= level
		@view			= "table"

		#A condition for deleting, updeting, editting the record
		@keyword		= ''

		_process_data(with, argv)
		unless @functions.empty?
			#preprocess data
			@functions.each do |function|
				send("preprocess_#{function}") if self.respond_to?("preprocess_#{function}", true)
			end

			foo = '='*10
			@functions.each do |function|
				#process application
				name = grn
				@app_contents[name] = "" unless @app_contents.has_key? name
				@app_contents[name] += "# == #{function} #{Time.now} #{foo}\n"
				@app_contents[name] += get_erb_content(function, 'applications')
				@app_contents[name] += "\n\n"

				#process template
				if self.respond_to?("process_template_#{function}", true)
					send("process_template_#{function}") 
				else
					@template_contents[gtn(function)] = get_erb_content(function)
				end
			end
		end

		puts @app_contents
		puts @template_contents
	end

	private

		def _process_data(with, argv)

			#function name => [parameter, parameter_alias, parameter_alias, ...]
			dwith = {}
			dwith['mode']	= ['mode']
			dwith['all']	= ['all']
			dwith['view']	= ['view_by', 'show_by', 'display_by', 'view',  'show', 'display']
			dwith['pager'] 	= ['page_size', 'pager', 'page', 'ps']
			dwith['search'] = ['search_by', 'search', 'src']
			dwith['rm'] 	= ['delete_by', 'delete', 'rm', 'remove', 'remove_by']
			dwith['edit'] 	= ['update_by', 'up', 'update', 'edit', 'edit_by']
			dwith['new'] 	= ['new', 'create']

			#enable default option
			@functions << 'view'
			if with != nil
				dwith.each do |key, val|
					val.each do |item|
						if with.include?(item)
							if item == 'disable' and @functions.include?(key)
								@functions.delete(key) 
							else
								@with[dwith[key][0]] = with[item] if item != 'enable'
								@functions << key
							end
							break
						end
					end
				end
			end

			@t = @with

			keyword = ['primary_key', 'Integer', 'index', 'foreign_key', 'unique']
			filter 	= ['index', 'foreign_key', 'unique']
			if argv.count > 0
				# For example,
				# primary_key:pid
				# Integer:aid
				# String:title
				# String:body
				argv.each do |item|
					key, val = item.split(":")
					unless filter.include?(key)
						@argv[val] = key 
					end
					if @keyword == '' and keyword.include?(key)
						@keyword = val.index(',') ? val.sub(/[,]/, '') : val
					end
				end
			end

			@keyword = @fields[0] if @keyword == ''
		end

		def preprocess_new
			@t['insert_sql'] = insert_sql = ''
			@fields.each do |item|
				insert_sql += ":#{item} => params[:#{item}],"
			end
			@t['insert_sql'] = insert_sql.chomp(',')
		end

		def preprocess_rm
			@t['delete_by'] = @keyword unless @t.include?('delete_by')
		end

		def preprocess_edit
			@t['update_sql'] = ''
			@t['update_by'] = @keyword unless @t.include?('update_by')
		end

		def preprocess_view
			@view = @with['mode'] if @with.include?('mode') and @mode.include?(@with['mode'])
		end

		def process_template_view
			@template_contents[gtn(@view)] = get_erb_content(@view)
		end

		def process_template_pager
			@template_contents[gtn(@view)] += get_erb_content('pager')
		end

		def process_template_search
			@template_contents[gtn(@view)] = get_erb_content('search') + @template_contents[gtn(@view)]
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
