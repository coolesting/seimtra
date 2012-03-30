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
		def setpath name, custom = false
			if custom == false 
				@path = name == nil ? 'Seimfile' : "modules/#{name}/info"
			else
				@path = name
				@path = File.expand_path(name) unless File.exist?(name)
			end
			@@options[@path] = {} unless @@options.include? @path
		end

		def init name = nil, custom = false
			setpath(name, custom)
			set :created, Time.now
			set :changed, Time.now
			set :version, Seimtra::Info::VERSION
			set :status, SCFG::OPTIONS[:status]
			set :open, SCFG::OPTIONS[:open]
			set :email, SCFG::OPTIONS[:email]
			set :author, SCFG::OPTIONS[:author]
		end

		def set key, val
			@@options[@path][key.to_s] = val
			unless @@changed.include? @path
				@@options[@path]['changed'] = Time.now
				@@changed << @path 
			end
		end

		def get key = nil
			key == nil ? @@options[@path] : @@options[@path][key.to_s]
		end

		def load name = nil, custom = false
			setpath(name, custom)
			if File.exist?(@path)
				content = ""
				content << File.read(@path)
				if content.index("\n") and content.index("=")
					content.split("\n").each do | con |
						key,val = con.split("=")
						@@options[@path][key] = val
					end
				end
			end
		end

		def save
			unless @@changed.empty?
				@@changed.each do |path|
					content = ""
					@@options[path].each do | key, val |
						content << "#{key}=#{val}\n"
					end
					File.open(path, 'w+') do |f|
						f.write(content)
					end
				end
			end
		end

	end

end

