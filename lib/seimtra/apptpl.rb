class Apptpl
		
	def initialize tpl_type, route_path
		@route_path	= route_path
		@tpl_type	= tpl_type
		@flowitmes	= [:vars, :str, :page, :sql, :tpl, :redirect]
	end

	def run data
		str = ''
		@flowitmes.each do | item |
			str += send("g_#{item.to_s}", data) if data.include? item
		end
		str
	end

	def g_vars data
		str = ''
		data[:vars].each do | key,val |
			str += "\t@#{key.to_s} = '#{val}'\n"
		end
		str
	end

	def g_page data
		arr = [
			"\t@page_id = #{data[:page][:page_id]}\n",
			"\t@page_size = #{data[:page][:page_size]}\n\n",
			"\t@page_id = params[:page_id] if params[:page_id] != nil",
			" and params[:page_id] > 0\n",
			"\t@page_offset = (@page_id.to_i - 1)*@page_size\n"
		]			
		arr.join
	end

	def g_str data
		"\t'#{data[:str]}'\n"
	end

	def g_sql data
		data[:sql]
\	end

	def g_tpl data
		"\t#{@tpl_type} :#{data[:tpl_name]}\n"
	end

	def g_redirect data
		"\tredirect '#{data[:redirect]}\n'"
	end

	##
	# == get_route_head
	#
	# == arguments
	# meth, String, route method
	# type, String, the event, :show, :new, edit, :rm
	def get_route_head meth = 'get', type = :show
		route_head = "#{meth} '/#{type.to_s}/#{@route_path}' do"
	end

end
