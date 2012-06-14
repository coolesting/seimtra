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

		if argv.length > 2
			module_name = options[:to] ? options[:to] : get_module
			file_name	= argv.shift

			files 				= {}
			files["route.app"] 	= "#{Sbase::Folders[:app]}/#{file_name}.rb" if options.route?
			files["view.tpl"] 	= "#{Sbase::Folders[:tpl]}/#{module_name}_#{file_name}.slim" if options.view?
			files["form.tpl"] 	= "#{Sbase::Folders[:tpl]}/#{module_name}_#{file_name}_form.slim" if options.form?

			files.each do | source, target |
				source = "tmp/#{source}"
				target = "modules/#{module_name}/#{target}"
				template(source, target) unless File.exist?(target)
			end
 		else
			error 'At least two more arguments.'
		end

	end

end
