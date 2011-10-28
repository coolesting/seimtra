class SeimtraThor < Thor

	desc "module_information [NAME]", "the information of current module"
	def module_information(name = nil)
	end

	desc "module_packup [NAME]", "Packup a module with some files"
	def module_packup(name = nil)
	end

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

end
