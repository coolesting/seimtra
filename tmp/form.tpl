form action="#{request.path}" method="post" id="form"
	ul.ul
		li : label menu
		li : input type="text" name="menu" required="required" value="#{@fields[:menu]}"

		li : label name
		li : input type="text" name="name" required="required" value="#{@fields[:name]}"

		li : label link
		li : input type="text" name="link" required="required" value="#{@fields[:link]}"

		li : label description
		li : textarea name="description" #{@fields[:description]}

		li : label status
		li : input type="number" name="status" min=0 max=99999 value="#{@fields[:status]}"

		li : label order
		li : input type="number" name="order" min=0 max=99999 value="#{@fields[:order]}"
