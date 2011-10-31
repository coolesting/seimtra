class SeimtraThor < Thor

	desc "module_born [NAME] [ALL]", "Initialize a module skeleton"
	def module_born(name, all = nil)
		if File.exist?(Dir.pwd + '/modules')
			empty_directory "modules/#{name}/routes"
			empty_directory "modules/#{name}/views"
			empty_directory "modules/#{name}/migrations"
			empty_directory "modules/#{name}/configs"
		else
			ask 'You need to enter root directory of your project'
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
	def module_information(name = nil)
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
