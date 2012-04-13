class SeimtraThor < Thor

	# = Generator
	#
	# Create the view for module
	#
	# == Arguments
	#
	# argv, 		string, more details please check the seimtra/generate.rb
	#
	# == Options
	#
	# --to, -t		specify a module for this operation
	#
	# == Examples 
	#
	# example 01, create a routes
	#
	# 	3s route get;login post;login
	#
	# example 02, create a table 
	#
	#	3s g table username:password:email
	#
	# example 03, create a list
	#
	# 	3s g list username:password:email
	#
	# example 04, create a form
	#
	#	3s g form text:username pawd:password text:email
	# 
	# example 05, create the example02-04 at once time
	#
	# 	3s g table username:password:email \ 
	# 	list username:password:email \
	# 	form text:username pawd:password text:email
	#

	desc "generate [ROUTE_NAME] [VIEW_TYPE] [ARGV]", "Generate the view for module"
	method_option :to, :type => :string, :aliases => '-t'
	map 'g' => :generate
	def generate(*argv)
		if argv.length > 0
			module_current = get_module options[:to]
			require "seimtra/generator"
			g = Generator.new module_current
			g.run argv
			g.contents.each do |path, content|
				if File.exist? path
					prepend_to_file path, content
				else
					create_file path, content
				end
			end
 		else
			error 'please check  "3s help generate" for usage of the command'
		end
	end

end
