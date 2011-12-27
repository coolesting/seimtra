class Utils
	
	@msg = ''
	
	class << self
		
		def check_module(name = nil)
			Dir['modules/*'].each do | module_name |
				m = module_name.split('/').last
				@msg = "The '#{m}' module has existed yet" if m == name
			end

			if @msg != '' 
				true
			else
				@msg = "The '#{name}' module is not existing"
				false
			end
		end

		def message
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

		def blank?(var)
			return true if var == nil

			type = var.class
			if type == 'Fixnum' or type == 'Float' or type == 'Numeric'
				return true if var.zero?
			end
			if type == 'String' or type == 'Array' or type == 'Hash'
				return true if var.empty?
			end

			false
		end
	end

end
