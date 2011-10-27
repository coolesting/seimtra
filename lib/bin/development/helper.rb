class SeimtraThor < Thor

	desc "module_packup [NAME]", "Packup a module with some files"
	def module_packup(name = nil)
	end

	desc "module_skeleton [NAME]", "Initialize a module skeleton"
	def module_skeleton(name)
		if File.exist?(Dir.pwd + '/modules')
			empty_directory "modules/#{name}/routes"
			empty_directory "modules/#{name}/views"
			empty_directory "modules/#{name}/migrations"
			empty_directory "modules/#{name}/configs"
		else
			ask 'You need to enter the root directory of your project'
		end
	end

end
