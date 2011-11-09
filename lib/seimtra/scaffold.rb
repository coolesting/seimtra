class Scaffold

	attr_accessor :route_file_content, :template_names

	def initialize(name, fields, argv, with, without)
		@name 		= name
		@argv 		= argv
		@fields 	= fields
		@with 		= {}
		@with_keys 	= ['search', 'pager']
		@actions 	= ['table', 'rm', 'new', 'edit']

		if with != nil
			@with.each do |k,v|
				@with[k] = v if @with_keys.include?(k)
			end
		end

		if without != nil
			without.each do |action|
				@actions.delete(action)
			end
		end

		@keys = @vals = []
		argv.each do |item|
			key, val = item.split(":")
			@keys << key
			@vals << val
			@vars[val] = key 
		end

		@actions.uniq!

		#implement the actions one by one
		unless @actions.empty?
			@actions.each do |action|
				send("action_#{action}".to_sym)
			end
		end
	end

	def template_content(name)
	end

	private

		def action_table
		end

		def action_rm
		end

		def action_new
		end

		def action_edit
		end
end
