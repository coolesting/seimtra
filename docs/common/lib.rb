def get_file file
	result = {}
	content = ''
	content << File.read(file) if File.exist? file
	if content.index("\n") and content.index("=")
		content.split("\n").each do | res |
			key,val = res.split("=")
			result[key] = val
		end
	end
	result
end

class Vars
	@vars = {}

	def self.get key
		@vars[key] if @vars.has_key? key
	end

	def self.set key, val
		@vars[key] = val
	end
end

def var key, val = ''
	unless val == ''
		Vars.set key, val
	else
		Vars.get key
	end
end
