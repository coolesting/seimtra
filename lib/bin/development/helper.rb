class SeimtraThor < Thor

	desc "packup [NAME]", "Packup some files to be an application package"
	def packup(name = nil)
	end

	desc "skeleton [NAME]", "Initialize a module skeleton"
	def skeleton(name)
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
