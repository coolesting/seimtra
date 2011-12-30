class SeimtraThor < Thor

	# = Generating module
	#
	# Create the application quickly
	#
	#
	# == Arguments
	#
	# name, 		string, file name generated
	#
	#
	# == Options
	#
	# --to, -t		put the specifying content to specifying module
	# --view, -v	generate the view with the specifying field
	# --routes		generate the routes
	#
	#
	# == Examples 
	# === Example 1
	#
	# create the migration of database
	#
	# 	3s db user String:username String:password String:email -a -r
	#
	# create a form for adding the user data
	#
	# 	3s g user --view=form text:username pawd:password
	#
	# finally, display the fields by list
	#
	# 	3s g user --view=username:email
	#
	#
	# === Example 2 
	# display by conditions
	#
	#	3s g usertable --view=table username:email
	#	3s g userform --view=form text:username text:password
	#	3s g userlist --view=list user
	#
	# create the routes
	#
	# 	3s g --route=get:login:logout:register post:login:register

	method_option :to, :type => :string, :aliases => '-t'
	method_option :view, :type => :array, :aliases => '-v'
	method_option :routes, :type => :array, :aliases => '-r'
	desc "generate [NAME] [ARGV]", "Generate the scaffold for module"
	def generate(name = nil)

		name			= SCFG.get(:module_focus) if name == nil 
		module_current 	= SCFG.get :module_focus
		empty_directory(Dir.pwd + '/modules') unless File.exist?(Dir.pwd + '/modules')

		#add the generation to existing module
		if options[:to] != nil
			module_current = options[:to] 
			return error(Utils.message) unless Utils.check_module(module_current)
		end

		goptions = {}
		goptions[:view] 	= options[:view] if options[:view] != nil
		goptions[:routes]	= options[:routes] if options[:routes] != nil

		require "seimtra/generator"
		g = Generator.new(name, module_current, goptions)

		g.app_contents.each do |path, content|
			if File.exist? path
				prepend_to_file path, content
			else
				create_file path, content
			end
		end

		g.template_contents.each do |path, content|
			create_file path, content
		end

	end

	##
	# = Operating the module
	#
	# create, remove, add, update, packup the module
	#
	#
	# == Arguments
	#
	# opt, string, a operating command
	# argv, array, the parameters
	#
	#
	# == Examples
	#
	# create the new module
	#
	# 	3s m new user
	#
	# show the list of modules
	#
	# 	3s m list
	#
	# show the info with specifying module
	#
	# 	3s m info user
	#
	# modify the module info
	#
	# 	3s m info user name:author_name

	desc "module [NAME] [ARGV]", "The module operation, create, remove, add"
	def module(opt, *argv) 
		
		#create the new module
		if opt == 'new'
			return say('You need a module name', "\e[31m") unless argv.length > 0
			name = argv.shift
			return error(Utils.message) if Utils.check_module(name)
# 			directory "docs/modules", "modules/#{name}"
			empty_directory "modules/#{name}/applications"
			create_file "modules/#{name}/applications/.log"

			empty_directory "modules/#{name}/templates"
			create_file "modules/#{name}/templates/.log"

			empty_directory "modules/#{name}/others"
			create_file "modules/#{name}/others/info.yml"
			create_file "modules/#{name}/others/.log"
			create_file "modules/#{name}/README.rdoc"

			path = Utils.get_custom_info.first
			SCFG.load path, true
			info = {}
			info[:name] 		= name
			info[:created] 		= Time.now
			info[:version] 		= '0.0.1'
			info[:email] 		= SCFG.get(:email) ? SCFG.get(:email) : ask("What is the email of your ?")
			info[:author]		= SCFG.get(:author) ? SCFG.get(:author) : ask("What is your name ?")
			info[:website] 		= SCFG::OPTIONS[:website] + "/seimtra-#{name}"
			info[:description] 	= ask("The description of the module ?")

			#set module config
			SCFG.load name
			info.each do |k,v|
				SCFG.set(k,v)
			end

			SCFG.load
			SCFG.set :module_focus, name

		# list the modules
		elsif opt == 'list'
			Dir[Dir.pwd + '/modules/*'].each do | m |
				say m.split('/').last, "\e[33m"
			end

		# show/set the module info
		elsif opt == 'info'
			name = SCFG.get(:module_focus)
			if argv.length > 0
				name = argv.shift if argv[0].index(':') != nil
			end
			
			say "========= #{name} module info ========= \n"
			show_info(name, argv)
		end

	end


	desc 'test [NAME]', 'Make a test, and output the result'
	method_option :with, :type => :string, :aliases => '-w'
	method_option :focus, :type => :boolean, :aliases => '-f'
	def test(func_name = nil, *argv)
		return error("Enter your test name likes this, 3s test db") if func_name == nil
		require "seimtra/stest"
		Dir[ROOTPATH + "/test/*"].each do | file |
			require file
		end
		t = Stest.new
		return error "The #{func_name} method is not existing." unless t.respond_to?(func_name)
		if argv.empty?
			t.send(func_name)
		else
			t.send(func_name, argv)
		end
	end

end
