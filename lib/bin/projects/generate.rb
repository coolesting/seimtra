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
	# 3s g table_name field1 field2 field3
	#

	desc "generate [TABLE_NAME] [FIELDS]", "Generate a scaffold for module"
	method_option :to, :type => :string, :aliases => '-t'
	map 'g' => :generate
	def generate *argv

		if argv.length > 2
			module_name = options[:to] ? options[:to] : get_module
			file_name	= argv.shift

			files 		= {
				"tmp/route.app"	=> "modules/#{module_name}/#{Sbase::Folders[:app]}/#{file_name}.rb",
				"tmp/view.tpl"	=> "modules/#{module_name}/#{Sbase::Folders[:tpl]}/#{file_name}.slim",
				"tmp/form.tpl"	=> "modules/#{module_name}/#{Sbase::Folders[:tpl]}/#{file_name}_form.slim"
			}

			files.each do | source, target |
				template(source, target) unless File.exist?(target)
			end
 		else
			error 'At least two more arguments.'
		end

	end

end
