class Stools
	
	class << self
		
		def check_module(name = nil)
			@msg = ''
			case name
			when nil
				@msg = ' The name could be not null'
			when 'admin'
				@msg = ' The name could be call "admin"'
			end
			@msg != '' ? false : true
		end

		def error
			@msg
		end
	end

end
