before do
	redirect '/' if settings.disable_routes.include?(request.path_info)
end
