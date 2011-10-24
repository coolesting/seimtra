require 'yaml'
class SCFG
	@@options = {}
	@@changed = false

	def self.init
		if File.exist?(Dir.pwd + SCONFIGS)
			@@options = YAML.load_file(Dir.pwd + SCONFIGS)
		else
			@@options['created'] = Time.now
			@@options['changed'] = Time.now
			@@options['module_repos'] = File.expand_path('../SeimtraRepos', Dir.pwd)
			@@changed = true
		end
	end

	def self.set(key, val)
		@@options[key] = val
		@@changed = true
	end

	def self.get(key)
		@@options[key]
	end

	def self.save
		if @@changed == true
			File.open(Dir.pwd + SCONFIGS, 'w+') do |f|
				f.write(YAML::dump(@@options))
			end
		end
	end

	def self.show
		@@options.each do |k,v|
			puts "#{k} : #{v}"
		end
	end
end

