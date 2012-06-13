class SeimtraThor < Thor

	desc "info [MODULE_NAME]", "Show the info of project, config and module"
	method_option :configs, :type => :boolean, :aliases => '-c'
	def info name = ''

		if name != ""
			error("The module #{name} is not existing") unless module_exist? name 
			result = SCFG.load :name => name, :return => true
			str = "#{name} module info"
		elsif options.configs?
			path = get_custom_info.first
			result = SCFG.load :path => path, :return => true
			str = "config file info of #{path}"
		else
			result = SCFG.load :return => true
			str = "current project info"
		end

		show_info(result, str)

	end

end
