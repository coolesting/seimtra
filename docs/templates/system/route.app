#display
get '/<%=@t[:module_name]%>/<%=@t[:file_name]%>' do

	sys_opt :new
	@<%=@t[:table_name]%> = DB[:<%=@t[:table_name]%>]
	slim :<%=@t[:module_name]%>_<%=@t[:file_name]%>

end

#new a record
get '/<%=@t[:module_name]%>/<%=@t[:file_name]%>/new' do

	sys_opt :save
	<%=@t[:file_name]%>_process_fields
	slim :<%=@t[:module_name]%>_<%=@t[:file_name]%>_form

end

post '/<%=@t[:module_name]%>/<%=@t[:file_name]%>/new' do

	<%=@t[:file_name]%>_process_fields
	DB[:<%=@t[:table_name]%>].insert(@fields)
	redirect "/<%=@t[:module_name]%>/<%=@t[:file_name]%>"

end

#delete the record
get '/<%=@t[:module_name]%>/<%=@t[:file_name]%>/rm/:<%=@t[:key_id]%>' do

	DB[:<%=@t[:table_name]%>].filter(:<%=@t[:key_id]%> => params[:<%=@t[:key_id]%>].to_i).delete
	redirect "/<%=@t[:module_name]%>/<%=@t[:file_name]%>"

end

#edit the record
get '/<%=@t[:module_name]%>/<%=@t[:file_name]%>/edit/:<%=@t[:key_id]%>' do

	sys_opt :save
	@fields = DB[:<%=@t[:table_name]%>].filter(:<%=@t[:key_id]%> => params[:<%=@t[:key_id]%>]).all[0]
 	<%=@t[:file_name]%>_process_fields
 	slim :<%=@t[:module_name]%>_<%=@t[:file_name]%>_form

end

post '/<%=@t[:module_name]%>/<%=@t[:file_name]%>/edit/:<%=@t[:key_id]%>' do

	<%=@t[:file_name]%>_process_fields
	DB[:<%=@t[:table_name]%>].filter(:<%=@t[:key_id]%> => params[:<%=@t[:key_id]%>].to_i).update(@fields)
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
			if data.include? :no_null
				data[:no_null].each do | field |
					throw_error "The #{fields} can not be empty." if field == ""
				end
			end
		end

	end

end
