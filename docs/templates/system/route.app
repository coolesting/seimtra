get '/<%=@t[:module_name]%>/<%=@t[:file_name]%>' do
	opt_events :new
	@<%=@t[:table_name]%> = DB[:<%=@t[:table_name]%>]
	slim :<%=@t[:module_name]%>_<%=@t[:file_name]%>
end

get '/<%=@t[:module_name]%>/<%=@t[:file_name]%>/new' do
	opt_events :save
	<%=@t[:file_name]%>_process_fields
	slim :<%=@t[:module_name]%>_<%=@t[:file_name]%>_form
end

get '/<%=@t[:module_name]%>/<%=@t[:file_name]%>/edit/:<%=@t[:key_id]%>' do

	opt_events :save, :remove
	@fields = DB[:<%=@t[:table_name]%>].filter(:<%=@t[:key_id]%> => params[:<%=@t[:key_id]%>]).all[0]

 	<%=@t[:file_name]%>_process_fields
 	slim :<%=@t[:module_name]%>_<%=@t[:file_name]%>_form

end

post '/<%=@t[:module_name]%>/<%=@t[:file_name]%>/new' do

	<%=@t[:file_name]%>_process_fields

	DB[:<%=@t[:table_name]%>].insert(@fields)

	redirect "/<%=@t[:module_name]%>/<%=@t[:file_name]%>"

end

post '/<%=@t[:module_name]%>/<%=@t[:file_name]%>/edit/:<%=@t[:key_id]%>' do

	<%=@t[:file_name]%>_process_fields

	dataset = DB[:<%=@t[:table_name]%>].filter(:<%=@t[:key_id]%> => params[:<%=@t[:key_id]%>].to_i)

	if dataset
		if params[:opt] == "Remove"
			dataset.delete
		elsif params[:opt] == "Save"
			dataset.update(@fields)
		end
	end

	redirect "/<%=@t[:module_name]%>/<%=@t[:file_name]%>"

end

helpers do

	def <%=@t[:file_name]%>_process_fields data = {}
		<%
			str = ""
			@t[:fields].each do | field |
				str += "\n\t\t\t:#{field}\t\t=> ''"
				str += "," if @t[:fields].last != field
			end 
		%>
		default_values = {<%=str%>
		}

		default_values.each do | k, v |
			unless @fields.include? k
				@fields[k] = params[k] ? params[k] : v
			end
		end

		unless data.empty?

			msg_num = 0

			if data.include? :no_null
				data[:no_null].each do | field |
					msg_num = 1 if field == ""
				end
			end

			send_error msg_num

		end

	end

end