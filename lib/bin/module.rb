class SeimtraThor < Thor
	desc "install module_name [OPTION]", "Install a module for your application"
	def install(*argv) 
		module_name = argv.shift
		argv
		#template('docs/modules/table/routes.tt', "routes/#{name}.rb")
	end

	desc "update", "Update your source list of module from remote to local repository "
	def update
	end

	desc "remove module_name", "Remove the module in your appliction with a module name"
	def remove(name = nil)
	end
end

