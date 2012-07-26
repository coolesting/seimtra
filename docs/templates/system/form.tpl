form action="#{request.path}" method="post" id="form"
	ul.ul<% @t[:fields].each do | field | %>
		<% field_type = @t[:types][field] %>
		<% if field_type == "string" %>
		li : label <%=field%>
		li : input type="text" name="<%=field%>" required="required" value="#{@fields[:<%=field%>]}"
		<% elsif field_type == "integer" %>
		li : label <%=field%>
		li : input type="number" name="<%=field%>" required="required" value="#{@fields[:<%=field%>]}" min="1" max="99999"
		<% elsif field_type == "text" %>
		li : label <%=field%>
		li : textarea name="<%=field%>" required="required" = @fields[:<%=field%>]
		<% elsif field_type == "datatime" %>
		li : label <%=field%>
		li : input type="datatime-local" name="<%=field%>" value="#{@fields[:<%=field%>]}"
		<% elsif field_type == "url" %>
		li : label <%=field%>
		li : input type="url" name="<%=field%>" value="#{@fields[:<%=field%>]}"
		<% elsif field_type == "time" %>
		li : label <%=field%>
		li : input type="time" name="<%=field%>" value="#{@fields[:<%=field%>]}"
		<% elsif field_type == "color" %>
		li : label <%=field%>
		li : input type="color" name="<%=field%>" value="#{@fields[:<%=field%>]}"
		<% end %>
		<% end %>
