def get_file file
	result = {}
	content = ''
	content << File.read(file) if File.exist? file
	if content.index("\n")
		content.split("\n").each do | line |
			unless line[0] == '"' and line.index("=")
				key,val = line.split("=")
				result[key] = val
			end
		end
	end
	result
end

def iset key, val
	set key, val
	DB[:settings].insert(:skey => key, :sval => val)
end
