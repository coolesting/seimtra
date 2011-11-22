class SeimtraThor < Thor

	desc "project_info [NAME]", "The information of current project or module"
	method_option :set, :type => :hash
	def project_info(module_name = nil)
		SCFG.load module_name if module_name != nil

		#set config
		if options[:set] != nil 
			options[:set].each do |key,val|
				SCFG.set key, val 
			end
		end

		#get config
		SCFG.get.each do |k,v| say "#{k} : #{v}", "\e[33m" end
	end

end
