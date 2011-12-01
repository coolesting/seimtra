class Utils
	
	class << self
		
		def check_module(name = nil)
			@msg = ''
			case name
			when nil
				@msg = ' The name could be not null'
			when 'admin'
				@msg = " The name could be call '#{name}'"
			when 'custom'
				@msg = " The name could be call '#{name}'"
			end
			@msg != '' ? false : true
		end

		def error
			@msg
		end

		def check_path
			path = Dir.pwd
			#windows
			if /\w:\\?/.match(path)
				path = 'c:\.Seimtra'
				file = 'echo '' > C:\.Semitra'
			#others
			else
				path = '~/.Seimtra'
				file = 'touch ~/.Seimtra'
			end
			[path,file]
		end
	end

end
