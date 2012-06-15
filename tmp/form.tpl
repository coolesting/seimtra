form action="#{request.path}" method="post" id="form"
	ul.ul<% @t[:fields].each do | field | %>
		li : label <%=field%>
		li : input type="text" name="<%=field%>" required="required" value="#{@fields[:<%=field%>]}"
		<% end %>
