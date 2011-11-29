class SeimtraThor < Thor

	desc "born [NAME]", "Born a module"
	method_option :focus, :type => :boolean, :aliases => '-f'
	def born(name = nil)

		unless Stools.check_module(name)
			return say(Stools.error, "\e[31m")
		end

		unless File.exist?(Dir.pwd + '/modules')
			empty_directory Dir.pwd + '/modules'
		end
		empty_directory "modules/#{name}/application"
		create_file "modules/#{name}/application/assets.rb"
		create_file "modules/#{name}/application/configures.rb"
		create_file "modules/#{name}/application/filter.rb"
		create_file "modules/#{name}/application/helpers.rb"
		create_file "modules/#{name}/application/routes.rb"

		empty_directory "modules/#{name}/templates"
		empty_directory "modules/#{name}/migrations"
		empty_directory "modules/#{name}/others"
		create_file "modules/#{name}/others/info"

		path = Stools.check_path.first
		SCFG.load path, true
		info = {}
		info['name'] 		= name
		info['created'] 	= Time.now
		info['version'] 	= '0.0.1'
		info['email'] 		= SCFG.get('email') ? SCFG.get('email') : ask("What is the email of your ?")
		info['author']		= SCFG.get('author') ? SCFG.get('author') : ask("What is your name ?")
		info['website'] 	= SCFG.get('website') ? SCFG.get('website') : ask("The website of the module ?")
		info['description'] = ask("The description of the module ?")

		SCFG.load name
		info.each do |k,v|
			SCFG.set(k,v)
		end

		if options.focus?
			SCFG.load
			SCFG.set('module_focus', name)
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

	method_option :module, :type => :string
	method_option :autocomplete, :type => :boolean, :aliases => '-a'
	method_option :fields, :type => :array, :aliases => '-f'
	method_option :run, :type => :boolean, :aliases => '-r' 
	method_option :with, :type => :hash, :aliases => '-w' 
	method_option :level, :type => :hash, :aliases => '-lv' 
	desc "generate [NAME] [OPTIONS]", "Generate the scaffold for module"
	#For example, 
	#3s mh user primary_id:uid String:name String:pawd
	#
	#3s mh article primary_id:aid String:title text:body --run
	#3s mh article String:title text:body --with=all:enable --run
	#3s mh article --fields=aid title --with=page_size:20
	#3s mh article --fields=aid title --with=search_by:title
	#3s mh article --fields=aid title --with=edit_by:aid delete_by:aid
	#3s mh article --fields=aid title --with=page_size:10 search_by:title
	#
	#3s mh post primary_id:pid String:title text:body --fields=pid title --run
	#3s mh --fields=title body --with=fields_by:pid --mode=list
	def generate(name, *argv)
		unless Stools.check_module(name)
			return say(Stools.error, "\e[31m")
		end
		return say("For example, 3s mh post primary_id:pid String:title text:body --run ", "\e[33m") unless argv.count > 0

		migrations 		= fields = []
		module_current 	= options[:module] == nil ? SCFG.get('module_focus') : options[:module]

		#auto add the primary_key and time to migrating record
		if argv.count > 0
			if options.autocomplete?
				db = Db.new
				return say(db.msg, '\e[31m') if db.error
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
			require "seimtra/scaffold"
			sf = Scaffold.new(name, module_current, fields, argv, options[:with], options[:level])

			#create route
			sf.route_contents.each do |route_name, route_content|
				create_file route_name, route_content
			end

			#create templates
			sf.template_contents.each do |tmp_name, tmp_content|
				create_file tmp_name, tmp_content
			end
		end

		#create/implement the migrations
		unless migrations.empty?
			run = {}; run[:run] = options.run? ? true : false
			invoke "migration", "create:#{name}", migrations, run, :module => module_current
		end
	end

	desc 'test', 'test'
	method_option :with, :type => :string, :aliases => '-w'
	method_option :focus, :type => :boolean, :aliases => '-f'
	def test(a = nil, *args)
		puts args if a!=nil 
	end

end
