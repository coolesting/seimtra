require 'yaml'
class SCFG
	@@options = {}
	@@changed = false

	class << self

		def install
			self.init
			@@changed = true
		end

		def init
			if File.exist?(Dir.pwd + SCONFIGS)
				@@options = YAML.load_file(Dir.pwd + SCONFIGS)
			else
				@@options['created'] = Time.now
				@@options['changed'] = Time.now
				@@options['version'] = Seimtra::Info::VERSION
				@@options['status'] = 'development'
				@@options['log'] = false
				@@options['log_path'] = Dir.pwd + '/log/command'
				@@options['module_repos'] = File.expand_path('../SeimtraRepos', Dir.pwd)
			end
			@@options['local_time'] = Time.now
		end

	def set(key, val)
		@@options[key] = val
		@@changed = true
	end

	def get(key = nil)
		key == nil ? @@options : @@options[key]
	end

	def save
		if @@changed == true
			@@options['changed'] = Time.now
			File.open(Dir.pwd + SCONFIGS, 'w+') do |f|
				f.write(YAML::dump(@@options))
			end
		end
	end

	end
end

