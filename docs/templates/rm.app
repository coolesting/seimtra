get "/rm/<%= @route_path %>/:id" do
	@<%= @module_name %> = DB[:<%= @module_name %>].filter(:<%= @t[:delete_by] %> => params[:id]).delete
	redirect '/<%= @module_name %>'
end

