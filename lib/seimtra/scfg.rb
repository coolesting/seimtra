require 'yaml'
class SCFG

	attr_accessor :msg

	@@options = @@msg = {}
	@@changed = []

	class << self

		#@name, string, file name
		#@custom, boolean,  a path you specify
		def setpath(name, custom = false)
			if custom == false 
				@path = name == nil ? 'Seimfile' : "modules/#{name}/info"
			else
				@path = name
				@path = File.expand_path(name) unless File.exist?(name)
			end
			@@options[@path] = {}
		end

		def init(name = nil, custom = false)
			setpath(name, custom)
			@@options[@path]['created'] = Time.now
			@@options[@path]['changed'] = Time.now
			@@options[@path]['version'] = Seimtra::Info::VERSION
			@@options[@path]['status'] 	= 'development'
			@@options[@path]['email']	= 'null'
			@@options[@path]['author'] 	= 'anonymous'
			@@changed << @path
		end

		def load(name = nil, custom = false)
			setpath(name, custom)
			if File.exist?(@path)
				if content = YAML.load_file(@path)
					@@options[@path] = content
				end
			end
		end

		def set(key, val)
			@@options[@path][key] = val
			@@changed << @path
		end

		def get(key = nil)
			key == nil ? @@options[@path] : @@options[@path][key]
		end

		def save
			unless @@changed.empty?
				@@changed.each do |path|
					@@options[path]['changed'] = Time.now
					File.open(path, 'w+') do |f|
						f.write(YAML::dump(@@options[path]))
					end
				end
			end
		end

	end

end

