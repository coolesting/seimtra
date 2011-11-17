class SeimtraThor < Thor

	desc "module_born [NAME]", "born a basic scafflod for developing module"
	def module_born(name = nil)
		unless File.exist?(Dir.pwd + '/modules')
			empty_directory Dir.pwd + '/modules'
		end
		return say("You need to enter a NAME for new module", "\e[31m") if name == nil

		info = {}
		empty_directory "modules/#{name}/routes"
		empty_directory "modules/#{name}/views"
		empty_directory "modules/#{name}/migrations"
		create_file "modules/#{name}/info" do
			info['name'] = name
			info['created'] = Time.now
			info['version'] = '0.0.1'

			info['email'] 	= SCFG.get('email')  
			info['author'] 	= SCFG.get('author')  

			info['email'] 	||= ask("What is the email of your ?")
			info['author']	||= ask("What is your name ?")

			info['website'] = ask("What is the website of the module ?")
			info['description'] = ask("The description of the module ?")
			YAML::dump(info)
		end
	end

	desc "module_addone [NAME] [OPTION]", "Add one of modules to your application"
	def module_addone(*argv) 
		module_name = argv.shift
		argv
		#template('docs/modules/table/routes.tt', "routes/#{name}.rb")
	end

	desc "module_update", "Update your source list of module from remote to local repository "
	def module_update
	end

	desc "module_remove [NAME]", "Remove the module in your appliction with a module name"
	def module_remove(name = nil)
	end

	desc "module_list", "A list of local module"
	def module_list(path = nil)
	end

	desc "module_info [NAME]", "the information of current module"
	method_option :name, :type => :string
	method_option :set, :type => :hash
	def module_info
		name = options[:name] != nil ? options[:name] : SCFG.get('module_focus')
		path = Dir.pwd + "/modules/#{name}/info"
		
		if options[:set] != nil
			file = YAML.load_file path
			info = file != false ? file : {}
			options[:set].each do |key, val|
				info[key] = val 
			end
			SCFG.save path, info, true
		end

		if File.exist?(path)
			file = YAML.load_file(path)
			if file != false
				file.each do |k, v|
					say "#{k} : #{v}", "\e[33m"
				end
			else
				say "Nothing in #{path}", "\e[31m"
			end
		end
	end

	desc "module_packup [NAME]", "Packup a module with some files"
	def module_packup(name = nil)
	end

	desc "module_focus [NAME]", "Focus on the module for developing"
	def module_focus(name = nil)
		if name != nil
			SCFG.set 'module_focus', name
			say "The #{name} module is focused", "\e[33m"
		else
			if SCFG.get('module_focus')
				say "Your current module is #{SCFG.get('module_focus')}", "\e[33m"
			else
				say "No module be focused on.", "\e[31m"
			end
		end
	end

	method_option :module, :type => :string
	method_option :display, :type => :array, :aliases => '-d'
	method_option :run, :type => :boolean, :aliases => '-r' 
	method_option :with, :type => :hash, :aliases => '-w' 
	method_option :level, :type => :hash, :aliases => '-lv' 
	desc "module_helper [NAME] [OPTIONS]", "The helper to create the module"
	#For example, 
	#3s mh user primary_id:uid String:name String:pawd
	#
	#3s mh article primary_id:aid String:title text:body --run
	#3s mh article --display=aid title --with=page_size:20
	#3s mh article --display=aid title --with=search_by:title
	#3s mh article --display=aid title --with=edit_by:aid delete_by:aid
	#3s mh article --display=aid title --with=page_size:10 search_by:title
	#
	#3s mh post primary_id:pid String:title text:body --display=pid title --run
	#3s mh --display=title body --with=display_by:pid list:title
	def module_helper(name, *argv)
		return say("The name can not be 'admin'", "\e[31m") if name == 'admin'
		return say("For example, 3s mh post primary_id:pid String:title text:body --run ", "\e[33m") unless argv.count > 0

		migrations 		= fields = []
		module_current 	= options[:module] == nil ? SCFG.get('module_focus') : options[:module]

		if argv.count > 0
			migrations = argv
			argv.each do |item|
				fields << item.split(":").last
			end
		end
		fields = options[:display] if options[:display] != nil

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
			invoke "db_migration", "create:#{name}", migrations, run, :module => module_current
		end
	end

	desc 'module_test', 'test'
	method_option :with, :type => :string, :aliases => '-w'
	method_option :focus, :type => :boolean, :aliases => '-f'
	def module_test(a = nil, *args)
		puts args if a!=nil 
	end

end
