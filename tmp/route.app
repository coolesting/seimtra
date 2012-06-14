get '/system/panel' do
	opt_events :new
	slim :system_panel
end

get '/system/panel/new' do
	opt_events :save
	panel_process_fields
	slim :system_panel_form
end

get '/system/panel/edit/:pid' do

	opt_events :save, :remove
	@fields = DB[:panel].filter(:pid => params[:pid]).all[0]

# 	@fields = DB[:panel].select(:pid, :menu, :name, :link, :description, :status, :order).filter(:pid => params[:pid]).all[0]

 	panel_process_fields
 	slim :system_panel_form

end

post '/system/panel/new' do

	panel_process_fields

	DB[:panel].insert(@fields)

	redirect "/system/panel"

end

post '/system/panel/edit/:pid' do

	panel_process_fields

	dataset = DB[:panel].filter(:pid => params[:pid].to_i)

	if dataset
		if params[:opt] == "Remove"
			dataset.delete
		elsif params[:opt] == "Save"
			dataset.update(@fields)
		end
	end

	redirect "/system/panel"

end

helpers do

	def panel_process_fields data = {}

		default_values = {
			:name			=> "",
			:link			=> "",
			:menu			=> "",
			:description	=> "",
			:status			=> 0,
			:order			=> 1
		}

		default_values.each do | k, v |
			unless @fields.include? k
				@fields[k] = params[k] ? params[k] : v
			end
		end

		unless data.empty?

			error_msg = 0

			if data.include? :no_null
				data[:no_null].each do | field |
					error_msg = 1 if field == ""
				end
			end

			send_error error_msg

		end

	end

end
