class SeimtraThor < Thor

	desc "info", "The info of current project"
	def info
		say "========= Current project info ========= \n"
		show_info
	end
end
