class SeimtraThor < Thor

	desc "info [ARGV]", "The info of current project"
	def info(*argv)
		say "========= Current project info ========= \n"
		show_info(nil, argv)
	end
end
