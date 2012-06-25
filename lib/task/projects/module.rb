class SeimtraThor < Thor
	
	desc "create [NAME]", "Create some directories of module structure"
	def create name
		error('The module is existing.') if module_exist?(name)
		module_init name

		info 				= {}
		path 				= get_custom_info.first
		res 				= SCFG.load :path => path, :return => true

		info[:name] 		= name
		info[:email] 		= res.include?('email') ? res['email'] : ask("What is the email of your ?")
		info[:author]		= res.include?('author') ? res['author'] : ask("What is your name ?")
		info[:description] 	= ask("The description of the module ?")

		File.open(Dir.pwd + "/modules/#{name}/" + Sbase::Files[:readme], "w+") do | f |
			f.write("## INTRODUCTION\n\n#{info[:description]}")
		end
			
		SCFG.load :path => 'Seimfile'
		SCFG.set 'module_focus', name

		SCFG.load :name => name, :init => true
		info.each do | key, val |
			SCFG.set key, val
		end
	end

	desc 'list', 'List all of the module folders'
	def list
		str = "module list"
		res = {}
		Dir[Dir.pwd + '/modules/*/' + Sbase::Files[:info]].each do | info |
			result = SCFG.load :path => info, :return => true
			if result.include?('name') and result.include?('description')
 				res[result['name']] = "#{result['description']} (#{result['open']})"
			end
		end
		show_info res, str
	end

	desc 'add [MODULE_NAMES]', 'Add a module to current system'
	method_option :remote, :type => :boolean, :aliases => '-r'
	method_option :path, :type => :string
	map "new" => :add
	def add *module_names

		ss = Seimtra_system.new
		modules = ss.check_module module_names
		error ss.msg if ss.error

		#run the db migration
		modules.each do | name |
			run "3s db -r --to=#{name}"
		end

		ss.add_module modules

		#bundle install each Gemfile
		modules.each do | name |
			if options.bundle?
				path = Dir.pwd + "/modules/#{name}/Gemfile"
				run "bundle install --gemfile=#{path}" if File.exist? path
			end
		end

	end

end
