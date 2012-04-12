## 
# == Usage
# Whatever you want to load any config file, you need to use the SCFG.load
# method, then, set or get the values by key.
#
# == Arguments of SCFG.load
# :name, module name
# :path, specifying complete path
# :return, return the values
# :current, load current options as the return values

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
		:open			=> "on",
		:load_order		=> 9
	}

	@@options = {}
	@@changed = []
	@@path	  = 'Seimfile'

	class << self

		#load config to the @@options by @@path
		def load options = {}

			result = {}
			isload = false
			content = ""

			@@path = options[:path] if options.include? :path
			@@path = "modules/#{options[:name]}/#{F_INFO}" if options.include? :name
			@@path = File.expand_path(@@path)
			isload = true if File.exist?(@@path)

			#load from config file
			if options.include?(:current) and @@options.include?(@@path)
				result = @@options[@@path]
			elsif isload == true
				content << File.read(@@path)
				if content.index("\n") and content.index("=")
					content.split("\n").each do | con |
						key,val = con.split("=")
						result[key] = val
					end
				end
			end

			@@options[@@path] = {} unless @@options.include?(@@path)
			@@options[@@path] = result

			if options.include? :init
				init
			end

			#return the result
			if options.include? :return
				result 
			else
				isload
			end
		end

		def set key, val
			changed
			@@options[@@path][key.to_s] = val
		end

		def get key
			@@options[@@path].include?(key.to_s) ? @@options[@@path][key.to_s] : ''
		end

		def init
			set :created, Time.now
			set :changed, Time.now
			set :version, Seimtra::Info::VERSION
			set :status, SCFG::OPTIONS[:status]
			set :open, SCFG::OPTIONS[:open]
			set :email, SCFG::OPTIONS[:email]
			set :author, SCFG::OPTIONS[:author]
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

		def changed
			unless @@changed.include? @@path
				@@options[@@path]['changed'] = Time.now
				@@changed << @@path 
			end
		end

	end

end
