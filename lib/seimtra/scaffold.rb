class Scaffold

	attr_accessor :template_names

	def initialize(name, fields, argv, with, without)
		@name 			= name
		@argv 			= argv
		@fields 		= fields
		@with_keys 		= ['search', 'page']
		@functions 		= ['show', 'rm', 'new', 'edit']
		@with			= {}
		@route_content 	= ''
		@template_names = []

		if with != nil
			@with.each do |k,v|
				@with[k] = v if @with_keys.include?(k)
			end
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
				send("preprocess_#{function}")
				#@template_names << function if check_temp(function) 
			end
		end
	end

	def get_template_content(name)
		get_erb_content(name, 'views')
	end

	def get_route_content
		@route_content
	end

	private

		def preprocess_show
		end

		def preprocess_page
			@page_size = @with['page']
		end

		def preprocess_rm
			@delete_by = ''
		end

		def preprocess_search
			@search_by = ''
		end

		def preprocess_new
		end

		def preprocess_edit
		end

		def get_erb_content(name, type)
		end

		#check the file, return true if the file is existing, otherwise false
		def check_temp(name)
		end
end
