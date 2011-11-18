require 'erb'	

class Scaffold

	attr_accessor :template_contents, :route_contents

	def initialize(name, mode, module_name, fields, argv, with, level)
		#@t, template variable in frontground
		@route_contents = @template_contents = @argv = @with = @t = {}
		@name 			= name
		@module_name	= module_name
		@fields 		= fields
		@functions 		= []
		@level 			= level
		@mode 			= mode

		#A condition for deleting, updeting, editting the record
		@keyword		= ''

		_process_data(with, argv)
		unless @functions.empty?
			#preprocess data
			@functions.each do |function|
				send("preprocess_#{function}") if self.respond_to?("preprocess_#{function}", true)
			end

			@functions.each do |function|
				#process route
				foo = '='*50
				@route_contents[grn(@name)] += "\n#== #{function} #{foo}\n"
				@route_contents[grn(@name)] += get_erb_content(function, 'routes')

				#process template
				if self.respond_to?("process_#{function}", true)
					send("process_#{function}") 
				else
					@template_contents[gtn(function)] = get_erb_content(function)
				end
			end
		end
	end

	private

		def _process_data(with, argv)

			#function name => parameter name
			display = {}
			display['view'] 	= ['view_by', 'view', 'show_by', 'show']
			display['pager'] 	= ['page_size', 'pager', 'page', 'ps']
			display['search'] 	= ['search_by', 'search', 'src']
			display['rm'] 		= ['delete_by', 'delete', 'rm', 'remove', 'remove_by']
			display['edit'] 	= ['update_by', 'up', 'update', 'edit', 'edit_by']
			display['new'] 		= ['new', 'create']

			#enable default option
			@functions << 'view'
			display.each do |key, val|
				val.each do |item|
					if with.include?(item)
						@with[display[key][0]] = with[item] if item != 'enable'
						@functions.delete(key) if item == 'disable' and @functions.include?(key)
						break
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

		def process_view
			@template_contents[gtn('view')] = get_erb_content('view')
		end

		def process_pager
			@template_contents[gtn('view')] += get_erb_content('pager')
		end

		def process_search
			@template_contents[gtn('view')] = get_erb_content('search') + @template_contents[gtn('view')]
		end

		#get route name
		def grn(name)
			"modules/#{@module_name}/routes/#{name}.rb"
		end

		#get template name
		def gtn(name)
			"modules/#{@module_name}/views/#{@name}_#{name}.slim"
		end

		def get_erb_content(name, type = 'views')
			path = ROOTPATH + "/docs/scaffolds/#{type}/#{name}.tt"
			if File.exists?(path)
				t = ERB.new(path)
				t.result(binding)
			else
				say("Nothing at path : #{path}", "\e[31m")
			end
		end

end
