class Utils
	
	class << self
		
		def check_module(name = nil)
			@msg = ''
			#names = ['admin', 'base', nil]

# 			if names.include?(name)
# 				@msg = " The name could be call '#{name.to_s}'"
# 			else
			Dir['modules/*'].each do | module_name |
				m = module_name.split('/').last
				@msg = "The '#{m}' module has existed yet" if m == name
			end
#			end

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
	end

end
