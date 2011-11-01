class SeimtraThor < Thor

	desc "project_information [OPTION]", "The information of current project"
	def project_information(*argv)
		if argv.count > 0 
			argv.each do |item|
				i = item.split(":")
				SCFG.set i.first, i.last
			end
		end
		SCFG.get.each do |k,v| say "#{k} : #{v}", "\e[33m" end
	end

end
