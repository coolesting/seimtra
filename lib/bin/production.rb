class SeimtraThor < Thor
	desc "install module_name", "Install the module from local repository to your application with a module name"
	def install(name = nil) 
	end

	desc "update", "Update your source list of module from remote to local repository "
	def update
	end

	desc "remove module_name", "Remove the module in your appliction with a module name"
	def remove(name = nil)
	end
end

