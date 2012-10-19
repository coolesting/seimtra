table.table
	thead<% @t[:fields].each do | field | %><% origin = field; field = @t[:assoc][field][2] if @t[:assoc].has_key?(field) %>
		th : a href="#{sys_url('/<%=@t[:layout]%>/<%=@t[:file_name]%>', :order => '<%=origin%>')}" = L[:<%=field%>]<% end %>
		th
	tbody<% unless @t[:assoc].empty? ; @t[:assoc].each do | field, data | %>
		- <%=data[0]%>s = <%=data[0]%>_record(:<%=data[1]%>, :<%=data[2]%>)<% end %><% end %>
		- @<%=@t[:file_name]%>.each do | row |
			tr<% @t[:fields].each do | field | if @t[:assoc].has_key? field %>
				td = <%=@t[:assoc][field][0]%>s[row[:<%=field%>]]<% else %>
				td = row[:<%=field%>]<% end %><% end %>
				td : a href="/<%=@t[:layout]%>/<%=@t[:file_name]%>/edit/#{row[:<%=@t[:key_id]%>]}" fix
				td : a href="/<%=@t[:layout]%>/<%=@t[:file_name]%>/rm/#{row[:<%=@t[:key_id]%>]}" del

- if @page_count > 1
	p.page_bar
		- for i in 1..@page_count
			- page_focus = i == @page_curr ? "page_focus" : ""
			a class="#{page_focus}" href="#{sys_url('/system/<%=@t[:file_name]%>', :page_curr => i)}" = i
			label &nbsp;&nbsp;
