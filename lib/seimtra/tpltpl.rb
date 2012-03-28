require 'erb'	
class Tpltpl
	
	def initialize
		@element_aliases = {
			"password" => "pawd",
			"submit" => "sub",
			"bootton" => "btn",
			"checkbox" => "ch"
		}
	end

	def g_table data
		"This is a table"
	end

	def g_list data
		str = ""
		str += "- if @data\n"
		str += "ul\n"
		str += "\t- for item in @data do\n"
		str += "\tli = itme\n"
		str += "- else\n"
		str += "\tp Nothing is here.\n"
		str
	end

	def g_form data
		attr = get_attr(data[:attr], data[:operator]) if data.include? :attr
		str = ""
		str += "form #{attr}\n"
		data[:element].each do | tailer, element |
			
			#aliases of the elements
			@element_aliases.each do | key, val |
				element = key if element == val
			end

			attrs = split_attr element, tailer

			case element
			when "select"
				str += "\tp #{attrs[:name]} : \n"
				str += "\tselect name=\"#{attrs[:name]}\"\n"
				if attrs[:val].class.to_s == "Array"
					attrs[:val].each do | itme |
						str += "\t\toption value=\"#{itme}\" #{itme}\n"
					end
				elsif attrs[:val].class.to_s == "Hash"
					attrs[:val].each do | key, val |
						str += "\t\toption value=\"#{key}\" #{val}\n"
					end
				else
					str += "\t\toption value=\"#{attrs[:val]}\" #{attrs[:val]}\n"
				end
			else
				str += "\tp #{attrs[:name]} : \n"
				str += "\tinput type=\"#{element}\" name=\"#{attrs[:name]}\" value = \"#{attrs[:val]}\"\n"
			end
		end
		str
	end

	def split_attr ele, tail
		val = src = ""

		count = tail.count ":"
		case count
		when 0
			name = tail
		when 1
			name, val = tail.split ":"
		when 2
			name, src, val = tail.split ":"
		end

		#get the value from source
		unless src == ""
		end

		res = {}
		res[:name] = name
		res[:val] = val.index(",") ? val.split(",") : val
		res
	end

	def get_attr attrs, opt
		str = ""
		return str if attrs == nil

		if opt == "form"
			method = attrs.include?(:method) ? attrs[:method] : 'post'
			action = attrs.include?(:action) ? attrs[:action] : ''
			str += "action = \"#{action}\" method = \"#{method}\" "
		end

		str += "id = \"#{data[:attr][:id]}\" "  if data[:attr].include?(:id)
		str += "class = \"#{data[:attr][:class]}\" "  if data[:attr].include?(:class)
		str
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
