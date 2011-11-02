class SeimtraThor < Thor

	desc "module_born [NAME]", "Initialize a module skeleton"
	def module_born(name = nil)
		unless File.exist?(Dir.pwd + '/modules')
			empty_directory Dir.pwd + '/modules'
		end

		info = {}
		name = "module_#{Time.now}" if name == nil
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

	desc "module_setup [NAME] [OPTION]", "Install a module for your application"
	def module_setup(*argv) 
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
	method_options :name => "index"
	def module_info(*argv)
		name = options[:name] == 'index' ? SCFG.get('module_focus') : options[:name]
		path = Dir.pwd + "/modules/#{name}/info"

		if argv.count > 0
			file = YAML.load_file path
			info = file != false ? file : {}
			argv.each do |item|
				key, val = item.split(":")
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

	desc "module_helper [OPTION]", "The helper to create the module"
	method_options :mode => 'table', :focus => 'index'
	def module_helper(*argv)
		focus	= options[:focus] == 'index' ? SCFG.get('module_focus') : options[:focus]
		mode 	= options[:mode]
		@name 	= argv.first == nil ? Time.now.strftime("%Y%m%d%H%M%S") : argv.first
		data 	= argv
		
		Dir[ROOTPATH + "/docs/scaffolds/#{mode}/routes/*.tt"].each do |source|
			template source, "modules/#{focus}/routes/#{@name}_#{mode}.rb"
		end

		Dir[ROOTPATH + "/docs/scaffolds/#{mode}/views/*.tt"].each do |source|
			ext = source.split("/").last.split(".").first
			template source, "modules/#{focus}/views/#{@name}_#{ext}.slim"
		end

		#implement the migration
	end

end
