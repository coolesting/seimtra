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
	# create a scaffold to system module
	#
	#	3s g table_name field1 field2 field3 --to=system
	#

	desc "generate [TABLE_NAME] [FIELDS]", "Generate a scaffold for module"
	method_option :to, :type => :string, :aliases => '-t'
	map 'g' => :generate
	def generate *argv

		error 'At least two more arguments.' unless argv.length > 2

		db					= Db.new
		module_name 		= options[:to] ? options[:to] : get_module
		data				= db.arrange_fields argv

		#set the template variables
		@t					= {}
		@t[:module_name]	= module_name
		@t[:file_name]		= data[:table]
		@t[:table_name]		= data[:table]

		#arrage the data fields
		@t[:key_id]			= data[:fields][0]
		@t[:fields]			= data[:fields]

		files 				= {}

		if module_name == "system"

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

			#add a panel link

		end

	end

end
