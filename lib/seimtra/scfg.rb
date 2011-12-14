require 'yaml'

class SCFG
	OPTIONS = {
		'status' 		=> 'development',
		'email'			=> 'empty',
		'author' 		=> 'administrator',
		'log' 			=> false,
		'log_path' 		=> Dir.pwd + '/log/default',
		'module_focus' 	=> 'custom',
		'module_repos' 	=> File.expand_path('~/SeimRepos')
		'website' 		=> "https://github.com/coolesting"
	}
end

class SCFG

	@@options = {}
	@@changed = []

	class << self

		##
		# @name, string, file name
		# @custom, boolean,  a path you specify
		def setpath(name, custom = false)
			if custom == false 
				@path = name == nil ? 'Seimfile' : "modules/#{name}/others/info.yml"
			else
				@path = name
				@path = File.expand_path(name) unless File.exist?(name)
			end
			@@options[@path] = {} unless @@options.include? @path
		end

		def init(name = nil, custom = false)
			setpath(name, custom)
			@@options[@path]['created'] = Time.now
			@@options[@path]['changed'] = Time.now
			@@options[@path]['version'] = Seimtra::Info::VERSION
			@@options[@path]['status'] 	= SCFG::OPTIONS['status']
			@@options[@path]['email']	= SCFG::OPTIONS['email']
			@@options[@path]['author'] 	= SCFG::OPTIONS['author']
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

