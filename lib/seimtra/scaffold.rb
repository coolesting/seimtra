require 'erb'	

class Scaffold

	attr_accessor :template_contents, :route_contents

	def initialize(name, fields, argv, with, level)
		@name 			= name
		@fields 		= fields
		@route_contents = @template_contents = @with = @t = {}
		@functions 		= []
		@level 			= level

		preprocess_data(with, argv)
		unless @functions.empty?
			@functions.each do |function|
				send("process_#{function}") if self.respond_to?("process_#{function}", true)
			end
		end
	end

	private

		def preprocess_data(with, argv)

			#enable default option
			@functions << 'admin' unless with.include?('admin')
			@functions << 'view' unless with.include?('view')

			display = {}
			#function name => parameter name
			display['pager'] 	= ['page_size', 'pager', 'page', 'ps']
			display['search'] 	= ['search_by', 'search', 'src']
			display['rm'] 		= ['delete_by', 'delete', 'rm', 'remove', 'remove_by']
			display['edit'] 	= ['update_by', 'up', 'update', 'edit', 'edit_by']
			display['new'] 		= ['new', 'create']

			display.each do |key, val|
				val.each do |item|
					if with.include?(item)
						@with[display[key][0]] = with[item] 
						@functions << key
						break
					end
				end
			end

			@t = @with

			@keys = @vals = []
			argv.each do |item|
				key, val = item.split(":")
				@keys << key
				@vals << val
				@vars[val] = key 
			end
			@t['insert_sql'] = ''
			@t['update_sql'] = ''

		end

		def process_view
			@route_contents += "\n#== view ==================================\n"
			@route_contents += get_erb_content('view', 'routes')
			@template_names << 'view'
			@template_contents[@name] = get_erb_content('view')
		end

		def process_pager
			@route_contents += "\n#== pager =================================\n"
			@route_contents += get_erb_content('page', 'routes')
			@template_contents[@name] += get_erb_content('page')
		end

		def process_rm
			@route_contents += "\n#== remove ================================\n"
			@route_contents += get_erb_content('rm', 'routes')
		end

		def process_search
			@route_contents += "\n#== search ================================\n"
			@route_contents += get_erb_content('search', 'routes')
			@template_contents[@name] = get_erb_content('search') + @template_contents[@name]
		end

		def process_new
			@route_contents += "\n#== new ===================================\n"
			@route_contents += get_erb_content('new', 'routes')
			@template_names << 'new'
			@template_contents["#{@name}_new"] = get_erb_content('new')
		end

		def process_edit
			@route_contents += "\n#== edit ==================================\n"
			@route_contents += get_erb_content('edit', 'routes')
			@template_names << 'edit'
			@template_contents["#{@name}_edit"] = get_erb_content('edit')
		end

		def process_admin
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
