get "/<%= @route_path %>" do 
	@title = '<%= @t[:title] %>'
	@<%= @module_name %> = DB["<%= @t[:select_sql] %>"]
	slim :<%= @module_name %>_<%= @t[:tpl_name] %>
end

