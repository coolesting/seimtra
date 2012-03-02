get "/new/<%= @t[:route_path] %>" do
<% if @t[:tpl_name] %>
	slim :<%= @t[:tpl_name] %>
<% end %>
end

post "/new/<%= @t[:route_path] %>" do
<% if @t[:insert_sql] %>
	@<%= @t[:name] %> = DB[:<%= @t[:name] %>].insert(<%= @t[:insert_sql] %>)
	redirect '/<%= @t[:route_path] %>'
<% end %>
end

