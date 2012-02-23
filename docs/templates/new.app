get "/new/<%= @route_path %>" do
	slim :<%= @module_name %>_new
end

post "/new/<%= @route_path %>" do
	@<%= @module_name %> = DB[:<%= @module_name %>].insert(<%= @t[:insert_sql] %>)
	redirect '/new/<%= @route_path %>'
end

