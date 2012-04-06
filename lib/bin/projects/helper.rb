class SeimtraThor < Thor

	desc "info [ARGV]", "Show the info of config file"
	def info *argv
		name = ''
		if argv.length > 0 
			name = argv.shift unless argv[0].index(":")
		end

		if name == 'config'
			SCFG.load(:path => get_custom_info.first, :return => true)
			str = "Your config info"
		else
			SCFG.load(:return => true)
			str = "Current project info"
		end

		if argv.length > 0
			argv.each do | item |
				if item.index ":"
					k, v = item.split ":"
					SCFG.set k,v
				end
			end
		end

		show_info(SCFG.load(:current => true, :return => true), str)
	end
end
