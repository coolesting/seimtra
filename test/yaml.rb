class Stest
	def yaml
		path = File.expand_path('./test.yml')
		content = {}

		content[:a] = 'aa'
		content[:b] = 'bb'

		unless content.empty?
			File.open(path, 'w+') do |f|
				f.write(YAML::dump(content))
			end
		end
		
		result = YAML.load_file(path) if File.exist? path
		print result[:a]
	end
end
