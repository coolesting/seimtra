form action="#{request.path}" method="post" id="form"
	ul.ul<% 
	@t[:fields].each do | field | 

		html_type = @t[:htmls][field]
		html_type = "unknown" if Sbase::Main_key.include? @t[:types][field].to_sym 
		lname = @t[:assoc].has_key?(field) ? @t[:assoc][field][2] : field

		if html_type == "unknown" %>
		<% elsif html_type == "string" %>
		li : label <%=lname%>
		li : input type="text" name="<%=field%>" required="required" value="#{@fields[:<%=field%>]}"
		<% elsif html_type == "integer" %>
		li : label <%=lname%>
		li : input type="number" name="<%=field%>" required="required" value="#{@fields[:<%=field%>]}" min="1" max="99999"
		<% elsif html_type == "text" %>
		li : label <%=lname%>
		li : textarea name="<%=field%>" required="required" = @fields[:<%=field%>]
		<% elsif html_type == "radio" %>
		li : label <%=lname%>
		- <%=@t[:assoc][field][0]%>s = <%=@t[:assoc][field][0]%>_record(:<%=@t[:assoc][field][1]%>, :<%=@t[:assoc][field][2]%>)
		li
			- <%=@t[:assoc][field][0]%>s.each do | k,v |
				- checked = @fields[:<%=@t[:assoc][field][1]%>] == k ? "checked" : ""
				input id="radio_<%=@t[:assoc][field][1]%>_#{k}" type="radio" name="<%=@t[:assoc][field][1]%>" checked="#{checked}" value="#{k}"
				label for="radio_<%=@t[:assoc][field][1]%>_#{k}" = v
				br
		<% elsif html_type == "select" %>
		li : label <%=lname%>
		- <%=@t[:assoc][field][0]%>s = <%=@t[:assoc][field][0]%>_record(:<%=@t[:assoc][field][1]%>, :<%=@t[:assoc][field][2]%>)
		li : select name="<%=@t[:assoc][field][1]%>" required="required"
			- <%=@t[:assoc][field][0]%>s.each do | k,v |
				- selected = @fields[:<%=@t[:assoc][field][1]%>] == k ? "selected" : ""
				option selected="#{selected}" value="#{k}" = v
		<% else %>
		li : label <%=lname%>
		li : input type="<%=html_type%>" name="<%=field%>" required="required" value="#{@fields[:<%=field%>]}"<% 
		end

	end %>
