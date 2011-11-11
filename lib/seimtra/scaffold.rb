require 'erb'	

class Scaffold

	attr_accessor :template_names

	def initialize(name, fields, argv, with, without)
		@name 			= name
		@argv 			= argv
		@fields 		= fields
		@functions 		= ['show', 'rm', 'new', 'edit', 'pager', 'search']
		@with			= @template_contents = {}
		@without 		= @template_names = []
		@route_content 	= ''

		@with 			= with
		@without 		= without

		@keys = @vals = []
		argv.each do |item|
			key, val = item.split(":")
			@keys << key
			@vals << val
			@vars[val] = key 
		end

		#preprocess the functions
		@functions.uniq!.each do |function|
			send("process_#{function}") if self.respond_to?("process_#{function}", true)
		end
	end

	def get_template_contents(name)
		@template_contents[name]	
	end

	def get_route_content
		@route_content
	end

	private

		def process_show
			@route_content += "\n#== display ===============================\n"
			@route_content += get_erb_content('show', 'routes')
			@template_names << 'show'
			@template_contents[@name] = get_erb_content('show')
		end

		def process_page
			@page_size = @with['page'].to_i
			@route_content += "\n#== pager =================================\n"
			@route_content += get_erb_content('page', 'routes')
			@template_contents[@name] += get_erb_content('page')
		end

		def process_rm
			@delete_by = ''
			@route_content += "\n#== remove ================================\n"
			@route_content += get_erb_content('rm', 'routes')
		end

		def process_search
			@search_by = @with['search']
			@route_content += "\n#== search ================================\n"
			@route_content += get_erb_content('search', 'routes')
			@template_contents[@name] = get_erb_content('search') + @template_contents[@name]
		end

		def process_new
			@insert_sql = ''
			@route_content += "\n#== new ===================================\n"
			@route_content += get_erb_content('new', 'routes')
			@template_names << 'new'
			@template_contents["#{@name}_new"] = get_erb_content('new')
		end

		def process_edit
			@update_by = ''
			@update_sql = ''
			@route_content += "\n#== edit ==================================\n"
			@route_content += get_erb_content('edit', 'routes')
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
