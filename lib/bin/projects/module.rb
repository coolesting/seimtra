class SeimtraThor < Thor

	# = generating module
	#
	# Create the application quickly

	# == arguments
	#
	# name, 		string 
	
	# == options
	#
	# --to, -t		put the specifying content to specifying module
	# --create, -c	create a module if the module is not existing
	# --autocomplete, -a completing the fileds with primary_key, and timestamp, 
	# 				automatically
	# --migration, -m create the migration
	# --run, -r		run the migrating record
	# --with, -w	add extre function, such as, pager:10
	# --view, -v	generate the view with the specifying field
	# --routes		generate the routes
	# --enable		enable the actions, such as, edit, new, rm
	# --style		enable specifying style, default is table

	# == Examples 
	#
	# === Example 1
	#
	# create a module step by step, 
	# first, generate a standard structure folder of module 
	#
	# 	3s g user --create
	# 	3s g users -c
	#
	# create the migration of database
	#
	# 	3s db user String:username String:password String:email -a -r
	#
	# create the routes and views, then open the file and edit it
	#
	# 	3s g --route=get_login get_register post_login post_register
	#
	# finally, display the fields, 'username', 'email', enable the actions 'edit', 'new', 'rm'
	# and, set the style, 'list'
	#
	# 	3s g user --view=username email --enable=edit new rm --style=list

	# === Example 2 
	#
	# display by conditions
	#
	#	3s g user --view=username email --with=view_by:username
	#
	# generate a module with pager, search, edit, delete and so on
	#
	#	3s g user_list -v=username email --with=pager:10
	#	3s g user_details -v=username email --with=view_by:uid
	#	3s g user_opt -v=aid title --with=edit_by:uid rm_by:uid

	method_option :to, :type => :string, :aliases => '-t'
	method_option :create, :type => :boolean, :aliases => '-c' 
# 	method_option :autocomplete, :type => :boolean, :aliases => '-a'
# 	method_option :migration, :type => :hash, :aliases => '-m'
# 	method_option :run, :type => :boolean, :aliases => '-r' 
	method_option :with, :type => :hash, :aliases => '-w' 
	method_option :view, :type => :array, :aliases => '-v'
	method_option :routes, :type => :hash, :aliases => '-r'
	method_option :enable, :type => :array, :aliases => ''
	method_option :style, :type => :string, :aliases => '-s'
	desc "generate [NAME] [OPTIONS]", "Generate the scaffold for module"
	def generate(name = nil)

		name			= SCFG.get(:module_focus) if name == nil 
# 		migration 		= options[:migration] != nil ? options[:migration] : []
		module_current 	= SCFG.get :module_focus
		empty_directory(Dir.pwd + '/modules') unless File.exist?(Dir.pwd + '/modules')

		#add the generation to existing module
		if options[:to] != nil
			module_current = options[:to] 
			return error(Utils.message) unless Utils.check_module(module_current)
		end

		#generate new module
		if options.create?
			module_current 	= name
			return error(Utils.message) if Utils.check_module(name)
			directory "docs/modules", "modules/#{name}"

			path = Utils.check_path.first
			SCFG.load path, true
			info = {}
			info[:name] 		= name
			info[:created] 		= Time.now
			info[:version] 		= '0.0.1'
			info[:email] 		= SCFG.get(:email) ? SCFG.get(:email) : ask("What is the email of your ?")
			info[:author]		= SCFG.get(:author) ? SCFG.get(:author) : ask("What is your name ?")
			info[:website] 		= SCFG::OPTIONS['website'] + "/seimtra-#{name}"
			info[:description] 	= ask("The description of the module ?")

			#set module config
			SCFG.load name
			info.each do |k,v|
				SCFG.set(k,v)
			end

			SCFG.load
			SCFG.set :module_focus, name
		end

# 		#generate the skeleton if the migration
# 		unless migration.empty?
# 			if options.autocomplete?
# 				db = Db.new
# 				return error(db.msg) if db.error
# 				migration = db.autocomplete(name, migration)
# 			end
# 
# 			#implement/run the migrations to database
# 			args = {}; args[:run] = options.run? ? true : false
# 			invoke :db, "create:#{name}", migration, args, :module => module_current
# 		end

		goptions = {}
		goptions[:view] 	= options[:view] if options[:view] != nil
		goptions[:routes]	= options[:routes] if options[:routes] != nil
		goptions[:enable] 	= options[:enable] if options[:enable] != nil
		goptions[:style] 	= options[:style] if options[:style] != nil
		goptions[:with] 	= options[:with] if options[:with] != nil

		require "seimtra/generator"
		g = Generator.new(name, module_current, goptions)

# 		g.app_contents.each do |path, content|
# 			if File.exist? path
# 				prepend_to_file path, content
# 			else
# 				create_file path, content
# 			end
# 		end
# 
# 		g.template_contents.each do |path, content|
# 			create_file path, content
# 		end

	end

	desc "addone [NAME] [OPTION]", "Add one of modules to your application"
	def addone(*argv) 
		module_name = argv.shift
		argv
		#template('docs/modules/table/routes.tt', "routes/#{name}.rb")
	end

	desc "update", "Update your source list of module from remote to local repository "
	def update
	end

	desc "remove [NAME]", "Remove the module in your appliction with a module name"
	def remove(name = nil)
	end

	desc "list", "The list about the modules, routes"
	def list(type = 'module')
		if type == 'module'
			Dir[Dir.pwd + '/modules/*'].each do | m |
				say m.split('/').last, "\e[33m"
			end
		end
	end

	desc "packup [NAME]", "Packup a module with some files"
	def packup(name = nil)
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
