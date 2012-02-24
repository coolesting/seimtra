<%= @t[:route_meth] %> "/<%= @t[:route_path] %>" do 
<% if @t[:vars] 
	@t[:vars].each do | key, val | %>
	@<%= key %> = '<%= val %>'
<% 	end
end %>
<% if @t[:select_sql] %>
	@<%= @t[:name] %> = DB["<%= @t[:select_sql] %>"]
<% end %>
<% if @t[:tpl_name] %>
	slim :<%= @t[:tpl_name] %>
<% end %>
end

