class SeimtraThor < Thor

	desc "info [MODULE_NAME]", "Show the info of project, config and module"
	method_option :configs, :type => :boolean, :aliases => '-c'
	def info name = ''

		if name != ""
			error("The module #{name} is not existing") unless module_exist? name 
			result = SCFG.load :name => name, :return => true
			str = "#{name} module infomation"
		elsif options.configs?
			path = get_custom_info.first
			result = SCFG.load :path => path, :return => true
			str = "configure infomation at #{path}"
		else
			result = SCFG.load :return => true
			str = "project infomation"
		end

		show_info(result, str)

	end

end
