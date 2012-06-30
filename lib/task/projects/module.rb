class SeimtraThor < Thor
	
	desc "create [NAME]", "Create some directories of module structure"
	map "new" => :create
	def create name
		error('The module is existing.') if module_exist?(name)
		module_init name

		info 				= {}
		path 				= get_custom_info.first
		cfg 				= SCFG.load :path => path, :return => true

		info[:name] 		= name
		info[:email] 		= cfg.include?('email') ? cfg['email'] : ask("What is the email of your ?")
		info[:author]		= cfg.include?('author') ? cfg['author'] : ask("What is your name ?")
		info[:description] 	= ask("The description of the module ?")

		File.open(Dir.pwd + "/modules/#{name}/" + Sbase::Files[:readme], "w+") do | f |
			f.write("## INTRODUCTION\n\n#{info[:description]}")
		end

		SCFG.load :name => name, :init => true
		info.each do | key, val |
			SCFG.set key, val
		end
	end

	desc 'list', 'List all of the module folders'
	def list
		str = "module list"
		res = []
		Dir[Dir.pwd + '/modules/*'].each do | path |
			res << path.split("/").last
		end
		show_info res, str
	end

	desc 'add [MODULE_NAMES]', 'Add a module to current system'
	method_option :remote, :type => :boolean, :aliases => '-r'
	method_option :path, :type => :string
	map "install" => :add
	map "update" => :add
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
