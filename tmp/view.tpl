table.table
	- display_fields = [:pid, :name, :link, :status, :description, :order]
	thead
		- display_fields.each do | item |
			th = L[item]
		th
	tbody
		- @panel.each do | row |
			tr
				- display_fields.each do | item |
					td = row[item]
				td : a href="/system/panel/edit/#{row[:pid]}" ->
