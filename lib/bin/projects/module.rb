class SeimtraThor < Thor
	
	long_desc <<-DOC
	DOC
	desc "new [NAME]", "Create a new module"
	def new name
		error('The module is existing.') if module_exist?(name)
		module_init name

		path 		= get_custom_info.first
		res 		= SCFG.load :path => path, :return => true
		info 		= {}

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
	end

	desc 'list', 'List all of the module folders'
	def list
		Dir[Dir.pwd + '/modules/*/' + F_INFO].each do | i |
			result = SCFG.load :path => i, :return => true
			if result.include?('name') and result.include?('description')
 				isay("#{result['name']} : #{result['description']} (#{result['open']})")
			end
		end
	end

	desc 'install [NAME]', 'Install the module'
	method_option :remote, :type => :boolean, :aliases => '-r'
	method_option :path, :type => :string
	method_option :bundle, :type => :boolean
	def install *module_names
		error "Please enter the module name you want to install" unless module_names.length > 0
		
		#check the module installation file whether it is existing
		module_names.each do | name |
			if options.remote?
			end
			path = Dir.pwd + "/modules/#{name}"
			path = options[:path] if options[:path] != nil
			error "No searching for module at path #{path}" unless module_exist? path, true
		end

		#run the db migration
		module_names.each do | name |
			run "3s db -r --to=#{name}"
		end

		db = Db.new

		#get the modules that is installed previously
		exist_modules = []
		if db.select(:modules).exists
			db.select(:modules).select(:mid, :module_name).each do | row |
				exist_modules << row[:module_name] unless exist_modules.include? row[:module_name] and row[:module_name] != nil
			end
		end

		#compare the exist_modules and install_modules,
		#delete the existing module if you don't want to install again
		install_modules = []
		module_names.each do | name |
			if exist_modules.empty? or exist_modules.include?(name) == false
				install_modules << name
			else
				isay "The '#{name}' module has been installed."
			end
		end

		#quit if no module to install
		exit if install_modules.empty?

		#mark down the installed module in database record
		install_modules.each do | name |
	  		db.insert(:modules, :module_name => name)
		end

		#flash the modules info with database record
		db_modules = db.select :modules

		#scan various file to database
		install_modules.each do | name |
			mid = db_modules[:module_name => name][:mid]

			#info file	
			path = Dir.pwd + "/modules/#{name}/" + F_INFO
			result = SCFG.load :path => path , :return => true
			unless result.empty?
				result.each do | item |
					key, val = item
					db.insert :infos, :ikey => key, :ival => val, :mid => mid
				end
			end

			#settings file
			path = Dir.pwd + "/modules/#{name}/settings.cfg"
			result = SCFG.load :path => path , :return => true
			unless result.empty?
				result.each do | item |
					key, val = item
					db.insert :settings, :skey => key, :sval => val, :mid => mid
				end
			end

			#menu file
			path = Dir.pwd + "/modules/#{name}/menus.list"
			result = SCFG.load :path => path , :return => true, :type => :list
 			unless result.empty?
				table_fields = db.select(:menus).columns!

				result2 = []
				if result.class.to_s == "Hash"
					result2 << result
				else
					result2 = result
				end

				result2.each do | line |
					options = {}
					line.each do | item |
						key, val = item	
						options[key.to_sym] = val if table_fields.include? key.to_sym
					end
 					db.insert :menus, options
				end

			end

			#link file
			exist_menus = db.select :menus

			#default menu name
			menu_name 	= "front"
			path 		= Dir.pwd + "/modules/#{name}/links.list"
			result 		= SCFG.load :path => path , :return => true, :type => :list

 			unless result.empty?
				table_fields = db.select(:links).columns!

				result2 = []
				if result.class.to_s == "Hash"
					result2 << result
				else
					result2 = result
				end

				result2.each do | line |
					options = {}
					line.each do | item |
						key, val = item	
						options[key.to_sym] = val if table_fields.include? key.to_sym
						menu_name = val if key == "menu"
					end
					options[:mid] = exist_menus[:name => menu_name][:mid]
 					db.insert :links, options
				end
			end

			#bundle install each Gemfile
			if options.bundle?
				path = Dir.pwd + "/modules/#{name}/Gemfile"
				run "bundle install --gemfile=#{path}" if File.exist? path
			end

		end

	end

end
