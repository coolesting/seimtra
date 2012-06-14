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
	#	3s g table_name field1 field2 field3 -rvf
	#

	desc "generate [TABLE_NAME] [FIELDS]", "Generate a scaffold for module"
	method_option :to, :type => :string, :aliases => '-t'
	method_option :route, :type => :boolean, :aliases => '-r'
	method_option :view, :type => :boolean, :aliases => '-v'
	method_option :form, :type => :boolean, :aliases => '-f'
	map 'g' => :generate
	def generate *argv

		error 'At least two more arguments.' unless argv.length > 2
		
		module_name 		= options[:to] ? options[:to] : get_module
		file_name			= argv.shift

		files 				= {}
		files["view.tpl"] 	= "#{Sbase::Folders[:tpl]}/#{module_name}_#{file_name}.slim" if options.view?
		files["form.tpl"] 	= "#{Sbase::Folders[:tpl]}/#{module_name}_#{file_name}_form.slim" if options.form?

		if options.route? or options.view? or options.form?
			files["route.app"] 	= "#{Sbase::Folders[:app]}/#{file_name}.rb" 
		end

		#set the template variables
		@t					= {}
		@t[:module_name]	= module_name
		@t[:file_name]		= file_name
		@t[:table_name]		= file_name
		@t[:key_id]			= argv[0]
		@t[:fields]			= argv

		files.each do | source, target |
			source = "tmp/#{source}"
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
