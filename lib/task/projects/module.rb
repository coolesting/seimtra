#
# == Description
# the file includes all of module task
#
# == Usage
# 3s new
# 3s list
# ...
#

class SeimtraThor < Thor

	long_desc <<-DOC
	== Description

	create a new module folder structure

	== Example

		3s new module_name	
	or
		3s new module_name2 --menu
	DOC

	desc "create [NAME]", "Create some directories of module structure"
	method_option :menu, :type => :boolean
	map "new" => :create
	def create name
		error('The module is existing.') if module_exist?(name)

		#create the basic folder of module
		module_init name

		info 				= {}
		cfg 				= Sfile.read config_path

		info 				= Sbase::Infos[:module]
		info[:name] 		= name
		info[:email] 		= cfg.include?(:email) ? cfg[:email] : ask("What is the email of your ?")
		info[:author]		= cfg.include?(:author) ? cfg[:author] : ask("What is your name ?")
		info[:description] 	= ask("The description of the module ?")

		#write the README.md file
		File.open(Dir.pwd + "/modules/#{name}/" + Sbase::Files[:readme], "w+") do | f |
			f.write("## INTRODUCTION\n\n#{info[:description]}")
		end

		#write the module_name/install/_mods.sfile file
		Sfile.write info, "modules/#{name}/#{Sbase::Files[:info]}"

		scfg = project_config

		#add menu of admin module
		if options.menu? or scfg.has_key? :auto_add_admin_menu
			#a menu to install/menu.sfile
			menu = {}
			menu[:name] = "#{name}"
			menu[:type] = "admin"
			menu[:link] = "/admin/#{name}"
			menu[:description] = "No description about the #{name}"
			Sfile.write menu, "modules/#{name}/#{Sbase::File_install[:menu]}"

			path = "modules/#{name}/#{Sbase::File_app[:routes]}"
			create_file path unless File.exist? path
			append_to_file path, "\nget '#{menu[:link]}' do\n\t_tpl :_default\nend\n"
		end

		run "3s update #{name}"
	end

	long_desc <<-DOC
	== Description

	list all of modules

	== Example

	3s list
	DOC

	desc 'list', 'List all of the module folders'
	def list
		str = "module list"
		res = []
		Dir[Dir.pwd + '/modules/*'].each do | path |
			res << path.split("/").last
		end
		show_info res, str
	end

	long_desc <<-DOC
	== Description

	install the module

	== Example

	3s install
	3s install specifying_module_name
	DOC

	method_option :bundle, :type => :boolean, :aliases => '-b'
	desc 'add [MODULE_NAMES]', 'Add a module to current module'
	map "install" => :add
	def add *module_names

		gem_install module_names if options.bundle?
		ss = Seimtra_system.new
		modules = ss.check_module module_names

		#throw the error
		error "No module to be installed" if modules == nil

		#run the db schema
		modules.each do | name |
			run "3s db -r --to=#{name}"
		end

		#inject the info to db
		ss.add_module modules

	end

	long_desc <<-DOC
	== Description

	update the module info to database if the module had been installed yet, 

	== Example

	3s update
	3s update specifying_module_name
	DOC

	method_option :bundle, :type => :boolean, :aliases => '-b'
	desc 'update [MODULE_NAMES]', 'update the module'
	def update *module_names

		gem_install module_names if options.bundle?
 		ss = Seimtra_system.new
 		modules = ss.check_module module_names
 
 		update_modules = []
		if modules == nil and module_names.empty?
			update_modules = ss.get_module
		else
			update_modules = module_names
		end

		update_modules.each do | name |
			run "3s db -r --to=#{name}"
		end

		ss.add_module update_modules
	end

	long_desc <<-DOC
	== Description

	fetch the module from remote repository

	== Example

	3s fetch module_name
	DOC

	desc 'fetch [MODULE_NAMES]', 'fetch a module by name from remote repository'
	def fetch *module_names
		git_repo_path = 'coolesting'

		#get module from remote
		module_names.each do | m |
			if File.exist? "modules/#{m}"
				isay "the modules/#{m} is existing ."
			else
				run "git clone git://github.com/#{git_repo_path}/seimtra-module-#{m}.git modules/#{m}"
			end
		end
	end

end
