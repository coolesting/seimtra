class SeimtraThor < Thor

	desc "project_information", "The information of current project"
	def project_information
		SCFG.get.each do |k,v|
			say "#{k} : #{v}", "\e[33m"
		end
	end

end
