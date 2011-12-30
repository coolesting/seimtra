class SeimtraThor < Thor

	desc "info [ARGV]", "The info of current project"
	def info(*argv)
		show_info(nil, argv, 'Current project info')
	end
end
