class Scaffold

	attr_accessor :route_file_content, :template_names

	def initialize(name, fields, argv, with, without)
		@name 		= name
		@argv 		= argv
		@fields 	= fields
		@with_keys 	= ['search', 'pager']
		@functions 	= ['show', 'rm', 'new', 'edit']
		@template_names = @with = {}
		@route_file_content = ''

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

		#implement the functions one by one
		unless @functions.empty?
			@functions.each do |function|
				send("function_#{function}".to_sym)
			end
		end
	end

	def template_content(name)
	end

	private

		def function_show
		end

		def function_rm
		end

		def function_new
		end

		def function_edit
		end
end
