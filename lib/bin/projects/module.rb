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
	# --skeleton, -s create the skeleton
	# --display, -d	display the specifying content with a skeleton.
	# --run, -r		run the migrating record
	# --with, -w	add extre function, such as, pager:10
	# --routes		generate the routes
	# --views		generate the view templates

	# == Examples 
	#
	# === Example 1
	#
	# create a module step by step, 
	# first, generate a standard structure folder of module 
	#
	# 	3s g user --create
	#
	# create the migration of database
	#
	# 	3s db user String:username String:password String:email -a -r
	#
	# create the routes and views, then open the file and edit it
	#
	# 	3s g --routes=get:login get:register post:login post:register --views=login register
	#
	# finally, display the result of record added
	#
	# 	3s g user --display=username email

	# === Example 2 
	#
	# if you feel some complex above the steps, you can do that with a command,
	# generate a skeleton
	#
	# 	3s g user -m=String:username String:password String:email -a -r -s
 
	# === Example 3
	#
	# display by conditions
	#
	#	3s g user --display=username email
	#
	# generate a module with pager, search, edit, delete and so on
	#
	#	3s g user_list -d=username email --with=pager:10
	#	3s g user_details -d=username email --with=view_by:uid
	#	3s g user_opt -d=aid title --with=edit_by:uid delete_by:uid

	method_option :to, :type => :string, :aliases => '-t'
	method_option :create, :type => :boolean, :aliases => '-c' 
	method_option :autocomplete, :type => :boolean, :aliases => '-a'
	method_option :migration, :type => :hash, :aliases => '-m'
	method_option :skeleton, :type => :boolean, :aliases => '-s'
	method_option :display, :type => :array, :aliases => '-d'
	method_option :run, :type => :boolean, :aliases => '-r' 
	method_option :with, :type => :hash, :aliases => '-w' 
	method_option :routes, :type => :hash
	method_option :views, :type => :array
	desc "generate [NAME] [OPTIONS]", "Generate the scaffold for module"
	def generate(name = nil)

		name			= SCFG.get(:module_focus) if name == nil 
		migration 		= options[:migration] != nil ? options[:migration] : []
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

		#generate the skeleton if the migration
		unless migration.empty?
			if options.autocomplete?
				db = Db.new
				return error(db.msg) if db.error
				migration = db.autocomplete(name, migration)
			end

			#implement/run the migrations to database
			args = {}; args[:run] = options.run? ? true : false
			invoke :db, "create:#{name}", migration, args, :module => module_current
		end

		#implement the generating action
		require "seimtra/generator"
		g = Generator.new(
			name, 
			module_current, 
			{
				:migration 	=> migration, 
				:skeleton	=> options[:skeleton], 
				:display	=> options[:display], 
				:routes		=> options[:routes], 
				:views		=> options[:views],
				:with		=> options[:with]
			}
		)

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

	desc "list", "A list of local module"
	def list(path = nil)
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
