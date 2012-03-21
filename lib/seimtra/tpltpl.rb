require 'erb'	
class Tpptpl

	def g_table
	end

	def g_list
	end

	def g_form
	end

	## 
	# == get_erb_content
	# get the ERB template content and parse the it
	#
	# == arguments
	# name, String, the name of template in the one of docs/templates/*
	def get_erb_content name
		path = ROOTPATH + "/docs/templates/#{name}"
		if File.exist? path
			content = File.read(path)
			t = ERB.new(content)
			t.result(binding)
		else
			"No such the file #{path}" 
		end
	end

end
