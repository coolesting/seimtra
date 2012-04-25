get '/css/:file_name' do
	static_file params[:file_name], 'css'
end

get '/images/:file_name' do
	static_file params[:file_name], 'images'
end

get '/files/:file_name' do
	static_file params[:file_name], 'files'
end

helper do
	def static_file file_name, folder

		module_name = file_name.index('_') ? file_name.split('_').first : ''
		file_type = file_name.index('.') ? file_name.split('.').last : ''
		path = settings.root + "/modules/#{module_name}/#{folder}/#{file_name}"

		if File.exsit? path
			file = File.new(path, "r") 
			send_file path, :type => file_type.to_sym

			if settings.static_file
				#save the file to public/type/filename
			end
		else
			"No file found at module #{module_name}/#{type}/#{file_name}"
		end
	end
end
