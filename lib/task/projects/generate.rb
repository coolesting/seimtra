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
	# create a scaffold of panel at system module
	#
	#	3s g table_name field1 field2 field3 -s
	#

	desc "generate [TABLE_NAME] [FIELDS]", "Generate a scaffold for module"
	method_option :to, :type => :string, :aliases => '-t'
	method_option :system, :type => :boolean, :aliases => '-s'
	method_option :autocomplete, :type => :boolean, :aliases => '-a'
	method_option :with, :type => :hash
	map 'g' => :generate
	def generate *argv

		error 'At least two more arguments.' unless argv.length > 2

		db					= Db.new
		module_name 		= options[:to] ? options[:to] : get_module

		auto				= options.autocomplete? ? true : false
		data				= db.arrange_fields argv, auto

		#set the template variables
		@t					= {}
		@t[:module_name]	= module_name
		@t[:file_name]		= data[:table]
		@t[:table_name]		= data[:table]

		#arrage the data fields
		@t[:key_id]			= data[:fields][0]
		@t[:fields]			= data[:fields]

		files 				= {}

		#add a scaffold for system module
		if options.system?

			@t[:module_name]	= "system"

			files["view.tpl"] 	= "#{Sbase::Folders[:tpl]}/#{@t[:module_name]}_#{@t[:file_name]}.slim"
			files["form.tpl"] 	= "#{Sbase::Folders[:tpl]}/#{@t[:module_name]}_#{@t[:file_name]}_form.slim"
			files["route.app"] 	= "#{Sbase::Folders[:app]}/#{@t[:file_name]}.rb" 

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
			panel_menu	= options[:menu] ? options[:menu] : "custom"
			panel_name	= options[:name] ? options[:name] : @t[:file_name]
			panel_des	= options[:description] ? options[:description] : ""

			path 		= "modules/#{module_name}/#{Sbase::File_install[:panel]}"
			panel 		= "\nmenu=#{panel_menu}"
			panel 		+= "\nname=#{panel_name}"
			panel 		+= "\nlink=/#{@t[:module_name]}/#{@t[:file_name]}"
			panel 		+= "\ndescription=#{panel_des}"

			append_to_file path, panel

		end

		run "3s db #{data[:table]} #{argv.join(' ')} --to=#{module_name}"
	end

end
