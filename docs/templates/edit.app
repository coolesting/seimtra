get "/edit/<%= @route_path %>/:id" do 
	@<%= @module_name %> = DB[:<%= @module_name %>][<%= @t[:update_by] %> => params[:id]]
	slim :<%= @module_name %>_edit
end

post "/edit/<%= @route_path %>/:id" do 
	@<%= @module_name %> = DB[:<%= @module_name %>].filter(<%= @t[:update_by] %> => params[:id]).update(<%= @t[:update_sql] %>)
	redirect '/edit/<%= @route_path %>/:id'
end

