require 'erb'	

class Scaffold

	attr_accessor :template_contents, :route_contents

	def initialize(name, fields, argv, with, level)
		@name 			= name
		@fields 		= fields
		@functions 		= @route_contents = @template_contents = @with = @t = {}
		@level 			= level

		@functions['admin'] = 'enable'
		preprocess_data(with, argv)
		#display in frontground
		unless @functions['display'].empty?
		end
		
		#background application
		if @functions['admin'] == 'enable'
# 		@admin_functions.uniq!.each do |function|
# 			send("process_#{function}") if self.respond_to?("process_#{function}", true)
		end
	end

	private

		def preprocess_data(with, argv)
			@keys = @vals = []
			argv.each do |item|
				key, val = item.split(":")
				@keys << key
				@vals << val
				@vars[val] = key 
			end

			display = {}
			display['pager'] 	= ['page_size', 'pager', 'page', 'ps']
			display['search'] 	= ['search_by', 'search', 'src']
			display['rm'] 		= ['delete_by', 'delete', 'rm', 'remove', 'remove_by']
			display['edit'] 	= ['update_by', 'up', 'update']
			display['new'] 		= ['new', 'create']
			display['admin']	= ['enable', 'disable']

			display.each do |key, val|
				val.each do |item|
					if with[item]
						@t[with[key][0]] = with[item] 
						@functions[key] = 'enable' 
						break
					end
				end
			end

			@t['insert_sql'] = ''
			@t['update_sql'] = ''

			@functions['admin'] = with['admin'] if with['admin']
		end

		def process_list
			@route_contents += "\n#== display ===============================\n"
			@route_contents += get_erb_content('show', 'routes')
			@template_names << 'show'
			@template_contents[@name] = get_erb_content('show')
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
