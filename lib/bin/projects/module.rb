class SeimtraThor < Thor

	##
	# = generating module
	#
	#
	# == arguments
	#
	# name, 		string, required
	# mrgration, 	string, choose, like user primary_key:uid, String:name
	# 				more details see the migration method 
	#
	#
	# == options
	#
	# --to, -t		by default, this options is null, so the generator will
	# 				create the new module, if the option be set, the generating
	# 				files will be puts into that module you specifying by option
	# --autocomplete, -a completing the fileds with primary_key, and timestamp, 
	# 				automatically
	# --field, -f	display the specifying fields.
	# --run, -r		run the migrating record of specifying module
	# --with, -w	by default, the generator will display a table, you could add
	# 				extre function with this options, 
	# --level, -lv	assign the privilege levles to the extra function for user
	# 
	#
	# == Examples 
	#
	# generate a standard module called books
	#
	# 	3s g books
	#
	# generate a module with creating some fields
	#
	#	3s g user primary_id:uid String:name String:pawd
	#
	# the function likes above, and runs the migration record
	#
	#	3s g article primary_id:aid String:title text:body --run
	#
	# generate a module with existing field
	#
	#	3s g article -f=aid title
	#
	# generate a module with pager, search, edit, delete and so on
	#
	#	3s g article -f=aid title --with=search_by:title
	#	3s g article -f=aid title --with=edit_by:aid delete_by:aid
	#	3s g article -f=aid title --with=page_size:10 search_by:title
	#	3s g article String:title text:body --with=all:enable --run
	#
	# display the specifying field in view, by default, if you have not used
	# the -f option, it will displays origin filed you type in prompt line
	#
	#	3s g post primary_id:pid String:title text:body -f=pid title --run
	#	3s g -f=title body --with=view_by:pid --with=mode:list
	#

	method_option :to, :type => :string, :aliases => '-t'
	method_option :autocomplete, :type => :boolean, :aliases => '-a'
	method_option :fields, :type => :array, :aliases => '-f'
	method_option :run, :type => :boolean, :aliases => '-r' 
	method_option :with, :type => :hash, :aliases => '-w' 
	method_option :level, :type => :hash, :aliases => '-lv' 
	desc "generate [NAME] [OPTIONS]", "Generate the scaffold for module"
	def generate(name, *argv)

		migrations 		= fields = []
		module_current 	= name

		unless File.exist?(Dir.pwd + '/modules')
			empty_directory Dir.pwd + '/modules'
		end

		#add the generation to existing module
		if options[:to] != nil
			module_current = options[:to] 
			return error(Utils.message) unless Utils.check_module(module_current)

		#generate new module
		else
			return error(Utils.message) if Utils.check_module(name)
			directory "docs/modules", "modules/#{name}"

			path = Utils.check_path.first
			SCFG.load path, true
			info = {}
			info['name'] 		= name
			info['created'] 	= Time.now
			info['version'] 	= '0.0.1'
			info['email'] 		= SCFG.get('email') ? SCFG.get('email') : ask("What is the email of your ?")
			info['author']		= SCFG.get('author') ? SCFG.get('author') : ask("What is your name ?")
			info['website'] 	= SCFG.get('website') ? SCFG.get('website') : ask("The website of the module ?")
			info['description'] = ask("The description of the module ?")

			#set module config
			SCFG.load name
			info.each do |k,v|
				SCFG.set(k,v)
			end

			SCFG.load
			SCFG.set('module_focus', name)
		end

		#auto add the primary_key and time to migrating record
		if argv.count > 0
			if options.autocomplete?
				db = Db.new
				return error(db.msg) if db.error
				argv = db.autocomplete(name, argv)
			end
			migrations = argv
			argv.each do |item|
				fields << item.split(":").last
			end
		end
		fields = options[:fields] if options[:fields] != nil

		#create the skeleton 
		unless fields.empty?
			require "seimtra/generator"
			g = Generator.new(name, module_current, fields, argv, options[:with], options[:level])

			#generate the app
			g.app_contents.each do |path, content|
				if File.exsit? path
					prepend_to_file path, content
				else
					create_file path, content
				end
			end

			#generate templates
			g.template_contents.each do |path, content|
				create_file path, content
			end
		end

		#create/implement the migrations
		unless migrations.empty?
			run = {}; run[:run] = options.run? ? true : false
			invoke "migration", "create:#{name}", migrations, run, :module => module_current
		end
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
	def test(func_name = nil)
		return error("Enter your test name likes this, 3s test db") if func_name == nil
		require "seimtra/test"
		Dir[ROOTPATH + "/test/*"].each do | file |
			require file
		end
		t = Stest.new(func_name)
		error t.msg if t.error
	end

end
