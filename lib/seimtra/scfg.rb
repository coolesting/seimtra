require 'yaml'
class SCFG

	attr_accessor :msg

	@@options = @@msg = {}
	@@changed = []

	class << self

		def setpath(name)
			@path = name == nil ? './Seimfile' : "./modules/#{name}/info"
		end

		def init(name)
			setpath(name)
			@@options[@path]['created'] = Time.now
			@@options[@path]['changed'] = Time.now
			@@options[@path]['version'] = Seimtra::Info::VERSION
			@@options[@path]['status'] 	= 'development'
			@@options[@path]['email']	= ''
			@@options[@path]['author'] 	= ''
			@@changed << @path
		end

		def load(name = nil)
			setpath(name)
			if File.exist?(@path)
				@@options[@path] = YAML.load_file(@path)
			else
				@@msg[@path] = "No such file #{@path}"
				false
			end
		end

		def set(key, val)
			@@options[@path] << {key => val}
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

