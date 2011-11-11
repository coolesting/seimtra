require 'erb'	

class Scaffold

	attr_accessor :template_names

	def initialize(name, fields, argv, with, without)
		@name 			= name
		@argv 			= argv
		@fields 		= fields
		@functions 		= ['show', 'rm', 'new', 'edit']
		@with			= @template_content = {}
		@route_content 	= ''
		@template_names = []

		if with != nil
			@functions += with
		end

		if without != nil
			without.each do |function|
				@functions.delete(function)
			end
		end

		@keys = @vals = []
		argv.each do |item|
			key, val = item.split(":")
			@keys << key
			@vals << val
			@vars[val] = key 
		end

		@functions.uniq!

		#implement the function
		unless @functions.empty?
			@functions.each do |function|
				@route_content += get_erb_content(function, 'routes')
				send("preprocess_#{function}") if self.respond_to?("preprocess_#{function}", true)
			end
		end
	end

	def get_template_content(name)
		@template_content[name]	
	end

	def get_route_content
		@route_content
	end

	private

		def preprocess_show
			@template_names << 'show'
			@template_content[@name] = get_erb_content('show')
		end

		def preprocess_page
			@page_size = @with['page'].to_i
			@template_content[@name] += get_erb_content('page')
		end

		def preprocess_rm
			@delete_by = ''
		end

		def preprocess_search
			@search_by = @with['search']
			@template_content[@name] = get_erb_content('search') + @template_content[@name]
		end

		def preprocess_new
			@insert_sql = ''
			@template_names << 'new'
			@template_content["#{@name}_new"] = get_erb_content('new')
		end

		def preprocess_edit
			@update_by = ''
			@update_sql = ''
			@template_names << 'edit'
			@template_content["#{@name}_edit"] = get_erb_content('edit')
		end

		def get_erb_content(name, type = 'views')
			path = ROOTPATH + "/docs/scaffolds/#{type}/#{name}.tt"
			if File.exists?(path)
				t = ERB.new(path)
				t.result(binding)
			else
				"Nothing at path : #{path}"
			end
		end

end
