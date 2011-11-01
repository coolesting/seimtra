class SeimtraThor < Thor

	desc "module_born [NAME] [ALL]", "Initialize a module skeleton"
	def module_born(name, all = nil)
		unless File.exist?(Dir.pwd + '/modules')
			empty_directory Dir.pwd + '/modules'
		end

		empty_directory "modules/#{name}/routes"
		empty_directory "modules/#{name}/views"
		empty_directory "modules/#{name}/migrations"
		info = {}
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

	desc "module_information [NAME]", "the information of current module"
	def module_information(name = nil, *argv)
		name = SCFG.get('current_module') if name == nil
		path = Dir.pwd + "/modules/#{name}/info"

		if argv.count > 0
			info = YAML.load_file path
			argv.each do |item|
				i = item.split(":")
				info[i.first] = i.last
			end
			SCFG.save path, info, true
		end

		if File.exist?(path)
			SCFG.show path
		end
	end

	desc "module_packup [NAME]", "Packup a module with some files"
	def module_packup(name = nil)
	end

	desc "module_focus [NAME]", "Focus on the module for developing"
	def module_focus(name = nil)
		if name != nil
			SCFG.set 'current_module', name
			say "Set the #{name} module to current developing module yet", "\e[33m"
		else
			if SCFG.get('current_module')
				say "Your current module is #{SCFG.get('current_module')}", "\e[33m"
			else
				say "No module be focused on.", "\e[31m"
			end
		end
	end

end
