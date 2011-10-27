class SeimtraThor < Thor
	desc "module_install name [OPTION]", "Install a module for your application"
	def module_install(*argv) 
		module_name = argv.shift
		argv
		#template('docs/modules/table/routes.tt', "routes/#{name}.rb")
	end

	desc "module_update", "Update your source list of module from remote to local repository "
	def module_update
	end

	desc "module_remove name", "Remove the module in your appliction with a module name"
	def module_remove(name = nil)
	end
end

