class SeimtraThor < Thor

	##
	# = Operating the module
	#
	# create, remove, add, update, packup the module
	#
	#
	# == Arguments
	#
	# opt, string, a operating command
	# argv, array, the parameters
	#
	#
	# == Examples
	#
	# create the new module
	#
	# 	3s m new user
	#
	# show the list of modules
	#
	# 	3s m list
	#
	# show the info with specifying module
	#
	# 	3s m info user
	#
	# modify the module info
	#
	# 	3s m info user name:author_name

	desc "module [OPERATOR] [ARGV]", "The module operation, create, remove, add"
	map 'm' => :module
	def module(opt, *argv) 
		empty_directory(Dir.pwd + '/modules') unless File.exist?(Dir.pwd + '/modules')
		
		#create the new module
		if opt == 'new'
			error('You need a module name, e.g, 3s m new user') unless argv.length > 0
			name = argv[0]
			error('The module is existing.') if module_exist?(name)

			module_init name

			path = get_custom_info.first
			res = SCFG.load :path => path, :return => true
			info = {}
			info[:name] 		= name
			info[:open] 		= SCFG::OPTIONS[:open]
			info[:load_order] 	= SCFG::OPTIONS[:load_order]
			info[:load_order] 	= SCFG::OPTIONS[:level]
			info[:created] 		= Time.now
			info[:version] 		= '0.0.1'
			info[:email] 		= res.include?('email') ? res['email'] : ask("What is the email of your ?")
			info[:author]		= res.include?('author') ? res['author'] : ask("What is your name ?")
			info[:website] 		= SCFG::OPTIONS[:website] + "/seimtra-#{name}"
			info[:description] 	= ask("The description of the module ?")

			File.open(Dir.pwd + "/modules/#{name}/" + F_README, "w+") do | f |
				f.write("## INTRODUCTION\n\n#{info[:description]}")
			end
			
			SCFG.load :path => 'Seimfile'
			SCFG.set 'module_focus', name

			SCFG.load :name => name
			info.each do |k,v|
				SCFG.set(k,v)
			end

		# list the modules
		elsif opt == 'list'
			Dir[Dir.pwd + '/modules/*/' + F_INFO].each do | i |
				res = SCFG.load :path => i, :return => true
				if res.include? 'name' and res.include? 'description'
 					isay("#{res['name']} : #{res['description']} (#{res['open']})")
				end
			end

		# show/set the module info
		elsif opt == 'info'
			name = SCFG.get :module_focus
			if argv.length > 0
				name = argv.shift if argv[0].index(':') == nil
			end
			error("The module #{name} is not existing") unless module_exist? name 

			if argv.length > 0
				SCFG.load :name => name
				argv.each do | item |
					k, v = item.split ":"
					SCFG.set k,v
				end
			end

			show_info(SCFG.load(:name => name, :return => true, :current => true), "#{name} module info")
		end
	end

end
