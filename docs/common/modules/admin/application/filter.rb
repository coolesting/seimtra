before do
	redirect '/' if Disable_routes.include?(request.path_info)
end
