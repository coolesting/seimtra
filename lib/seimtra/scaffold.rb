require 'erb'	

class Scaffold

	attr_accessor :template_contents, :route_contents

	def initialize(name, fields, argv, with, level)
		@name 			= name
		@argv 			= argv
		@fields 		= fields
		@functions 		= ['list', 'rm', 'new', 'edit', 'pager', 'search']
		@route_contents = @template_contents = {}
		@with 			= with != nil ? with : {}
		@level 			= level

		@keys = @vals = []
		argv.each do |item|
			key, val = item.split(":")
			@keys << key
			@vals << val
			@vars[val] = key 
		end

		#preprocess the functions
		process_data
		@functions.uniq!.each do |function|
			send("process_#{function}") if self.respond_to?("process_#{function}", true)
		end
	end

	private

		def process_data
		end

		def process_list
			@route_contents += "\n#== display ===============================\n"
			@route_contents += get_erb_content('show', 'routes')
			@template_names << 'show'
			@template_contents[@name] = get_erb_content('show')
		end

		def process_page
			@page_size = @with['page'].to_i
			@route_contents += "\n#== pager =================================\n"
			@route_contents += get_erb_content('page', 'routes')
			@template_contents[@name] += get_erb_content('page')
		end

		def process_rm
			@delete_by = ''
			@route_contents += "\n#== remove ================================\n"
			@route_contents += get_erb_content('rm', 'routes')
		end

		def process_search
			@search_by = @with['search']
			@route_contents += "\n#== search ================================\n"
			@route_contents += get_erb_content('search', 'routes')
			@template_contents[@name] = get_erb_content('search') + @template_contents[@name]
		end

		def process_new
			@insert_sql = ''
			@route_contents += "\n#== new ===================================\n"
			@route_contents += get_erb_content('new', 'routes')
			@template_names << 'new'
			@template_contents["#{@name}_new"] = get_erb_content('new')
		end

		def process_edit
			@update_by = ''
			@update_sql = ''
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
