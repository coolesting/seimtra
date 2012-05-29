helpers do
	def menu_focus path
		request.path == path ? "focus" : ""
	end

	def opt_events *argv
		set :opt_events, argv
	end
end
