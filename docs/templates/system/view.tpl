table.table
	thead<% @t[:fields].each do | field | %>
		th = L[:<%=field%>]<% end %>
		th
	tbody
		- @<%=@t[:file_name]%>.each do | row |
			tr<% @t[:fields].each do | field | %>
				td = row[:<%=field%>]<% end %>
				td : a href="/<%=@t[:module_name]%>/<%=@t[:file_name]%>/edit/#{row[:<%=@t[:key_id]%>]}" fix
				td : a href="/<%=@t[:module_name]%>/<%=@t[:file_name]%>/rm/#{row[:<%=@t[:key_id]%>]}" del
