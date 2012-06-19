class SeimtraThor < Thor

	# = Generator
	#
	# Create the scaffold for module
	#
	# == Arguments
	#
	# argv, 		table name, field1, field2, field3 ...
	#
	# == Options
	#
	# --to, -t		specify a module for this operation
	#
	# == Examples 
	#
	# create a scaffold
	#
	#	3s g table_name field1 field2 field3
	#

	desc "generate [TABLE_NAME] [FIELDS]", "Generate a scaffold for module"
	method_option :to, :type => :string, :aliases => '-t'
	method_option :system, :type => :boolean, :aliases => '-s'
	map 'g' => :generate
	def generate *argv

		error 'At least two more arguments.' unless argv.length > 2
		
		module_name 		= options[:to] ? options[:to] : get_module
		file_name			= argv.shift

		#set the template variables
		@t					= {}
		@t[:module_name]	= module_name
		@t[:file_name]		= file_name
		@t[:table_name]		= file_name
		@t[:key_id]			= argv[0]
		@t[:fields]			= argv

		files 				= {}

		if options.system?

			files["view.tpl"] 	= "#{Sbase::Folders[:tpl]}/#{module_name}_#{file_name}.slim"
			files["form.tpl"] 	= "#{Sbase::Folders[:tpl]}/#{module_name}_#{file_name}_form.slim"
			files["route.app"] 	= "#{Sbase::Folders[:app]}/#{file_name}.rb" 

			files.each do | source, target |
				source = "#{Sbase::Paths[:tpl_system]}/#{source}"
				target = "modules/#{module_name}/#{target}"
				unless File.exist?(target)
					template(source, target)
				else
					content = get_erb_content source
					append_to_file target, content
				end
			end

		end


	end

end
