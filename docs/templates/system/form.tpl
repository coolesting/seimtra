form action="#{request.path}" method="post" id="form"
	ul.ul<% @t[:fields].each do | field | %>
		<% if @t[:types].include? field %>
		li : label <%=field%>
		li : input type="text" name="<%=field%>" required="required" value="#{@fields[:<%=field%>]}"
		<% else %>
		li : label <%=field%>
		li : input type="text" name="<%=field%>" required="required" value="#{@fields[:<%=field%>]}"
		<% end %>
		<% end %>
