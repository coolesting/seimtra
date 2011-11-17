require 'erb'	

class Scaffold

	attr_accessor :template_contents, :route_contents

	def initialize(name, module_name, fields, argv, with, level)
		# @f, template variable of frontground
		# @a, template variable of background
		@route_contents = @template_contents = @argv = @with = @f = @a = {}
		@name 			= name
		@module_name	= module_name
		@fields 		= fields
		@functions 		= []
		@level 			= level

		_process_data(with, argv)
		unless @functions.empty?
			#preprocess data
			@functions.each do |function|
				send("preprocess_#{function}") if self.respond_to?("preprocess_#{function}", true)
			end

			@functions.each do |function|
				#process route
				@route_contents[grn(@name)] += "\n#\t\t\t=== #{function} ===\n"
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
			display['admin'] 	= ['admin']

			#enable default option
			@functions << 'view'
			@functions << 'admin'
			display.each do |key, val|
				val.each do |item|
					if with.include?(item)
						@with[display[key][0]] = with[item] if item != 'enable'
						@functions.delete(key) if item == 'disable' and @functions.include?(key)
						break
					end
				end
			end

			@f = @a = @with

			if argv.count > 0
				# For example,
				# primary_key:pid
				# Integer:aid
				# String:title
				# String:body
				argv.each do |item|
					key, val = item.split(":")
					@argv[val] = key 
				end
			end

			@f['insert_sql'] = ''
			@f['update_sql'] = ''

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

		def process_admin
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
