class Scaffold

	attr_accessor :route_file_content, :template_names

	def initialize(name, fields, argv, with, without)
		@name 		= name
		@argv 		= argv
		@fields 	= fields
		@with 		= with
		@without	= without

		argv.each do |item|
			key, val = item.split(":")
			@keys << key
			@vals << val
			@vars[val] = key 
		end
	end

	def template_content(name)
	end
end
