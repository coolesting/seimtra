require 'yaml'

class SCFG

	OPTIONS = {
		:status 		=> 'development',
		:email			=> 'empty',
		:author 		=> 'administrator',
		:log 			=> false,
		:log_path 		=> Dir.pwd + '/log/default',
		:module_focus 	=> 'front',
		:module_repos 	=> File.expand_path('~/SeimRepos'),
		:website 		=> "https://github.com/coolesting",
		:open			=> "on"
	}

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
			set :created, Time.now
			set :changed, Time.now
			set :version, Seimtra::Info::VERSION
			set :status, SCFG::OPTIONS[:status]
			set :open, SCFG::OPTIONS[:open]
			set :email, SCFG::OPTIONS[:email]
			set :author, SCFG::OPTIONS[:author]
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
			@@options[@path][key.to_s] = val
			unless @@changed.include? @path
				@@options[@path]['changed'] = Time.now
				@@changed << @path 
			end
		end

		def get(key = nil)
			key == nil ? @@options[@path] : @@options[@path][key.to_s]
		end

		def save
			unless @@changed.empty?
				@@changed.each do |path|
					File.open(path, 'w+') do |f|
						f.write(YAML::dump(@@options[path]))
					end
				end
			end
		end

	end

end

