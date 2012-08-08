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

- if @page_count > 1
	p.page_bar
		- for i in 1..@page_count
			- page_focus = i == @page_curr ? "page_focus" : ""
			a class="#{page_focus}" href="/system/<%=@t[:file_name]%>?page_curr=#{i}" = i
			label &nbsp;&nbsp;
