get "/rm/<%= @t[:route_path] %>/:id" do
	@<%= @t[:name] %> = DB[:<%= @t[:name] %>].filter(:<%= @t[:delete_by] %> => params[:id]).delete
	redirect '/<%= @t[:route_path] %>'
end

