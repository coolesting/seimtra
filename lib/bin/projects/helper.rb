class SeimtraThor < Thor

	desc "info [NAME]", "Show the info of project, config and module"
	method_option :project, :type => :boolean, :aliases => '-p'
	method_option :configs, :type => :boolean, :aliases => '-c'
	def info name = ''

		if options.configs?
			path = get_custom_info.first
			result = SCFG.load :path => path, :return => true
			str = "config file info of #{path}"
		elsif options.project?
			result = SCFG.load :return => true
			str = "current project info"
		else
 			name = name == '' ? SCFG.get(:module_focus) : name
			error("The module #{name} is not existing") unless module_exist? name 
			result = SCFG.load :name => name, :return => true
			str = "#{name} module info"
		end

		show_info(result, str)

	end
end
