get "/edit/<%= @t[:route_path] %>/:id" do
<% if @t[:select_by] %>
	@<%= @t[:name] %> = DB[:<%= @t[:name] %>][<%= @t[:select_by] %> => params[:id]]
	slim :<%= @t[:tpl_name] %>
<% end %>
end

post "/edit/<%= @t[:route_path] %>/:id" do
<% if @t[:update_by] and @t[:update_sql] %>
	@<%= @t[:name] %> = DB[:<%= @t[:name] %>].filter(<%= @t[:update_by] %> => params[:id]).update(<%= @t[:update_sql] %>)
	redirect '/edit/<%= @t[:tpl_name] %>/:id'
<% end %>
end

