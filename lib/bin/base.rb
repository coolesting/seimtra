class SeimtraThor < Thor
	include Thor::Actions
	
	desc "new [NAME]", "Create a project with the name given"
	def new(project_name = 'seimtra_project', mode = 'production')
		directory 'docs/common', project_name
		SCFG.init
		SCFG.set :log, SCFG::OPTIONS[:log]
		SCFG.set :log_path, SCFG::OPTIONS[:log_path]
		SCFG.set :module_focus, SCFG::OPTIONS[:module_focus]
		SCFG.set :module_repository, SCFG::OPTIONS[:module_repos]

		if mode == 'production'
			directory 'docs/production', project_name
			SCFG.set :status, 'production'
			Dir.chdir(Dir.pwd + '/' + project_name)
			run("bundle install")
			isay "Initializing complete."
		else
			directory 'docs/development', project_name
			SCFG.set :status, 'development'
			Dir.chdir(Dir.pwd + '/' + project_name)
			isay "Using 'bundle install' command for intalling completely"
		end
	end

	desc "version", "The version of Seimtra"
	def version
		require 'seimtra/info'
		Seimtra::Info::constants(false).each do |name|
			isay "#{name.to_s.downcase} : #{eval("Seimtra::Info::" + name.to_s)}"
		end
	end

	desc "config [ARGV]", "Your customize config"
	def config(*argv)
		path, file = Utils.get_custom_info
		run (file) unless File.exists?(File.expand_path(path))
		show_info path, argv, "Your customize config", true
	end


end

class SeimtraThor < Thor

	#build-in method of the class
	no_tasks do

		# return ture if the module is existing
		def module_exist?(name)
			Dir['modules/*'].each do | module_name |
				m = module_name.split('/').last
				return true if m == name
			end
			false
		end

		# return the real module name, others is default module in config file
		def get_module name
			curmod = name == nil ? SCFG.get(:module_focus) : name
			error("The module #{curmod} is not existing") unless module_exist? curmod 
			curmod
		end

		# get the customize info
		def get_custom_info 
			path = Dir.pwd
			#windows
			if /\w:\\?/.match(path)
				path = 'c:\.Seimtra'
				file = 'echo '' > C:\.Semitra'
			#others
			else
				path = '~/.Seimtra'
				file = 'touch ~/.Seimtra'
			end
			[path,file]
		end

		def blank?(var)
			return true if var == nil

			type = var.class
			if type == 'Fixnum' or type == 'Float' or type == 'Numeric'
				return true if var.zero?
			end
			if type == 'String' or type == 'Array' or type == 'Hash'
				return true if var.empty?
			end

			false
		end

		#create some folders and files that depends on the structure of module
		def module_init name
			folders = ['applications', 'templates', 'others', 'languages'] 
 			folders.each do | folder |
				path = "modules/#{name}/#{folder}"
				empty_directory(path) unless File.exist? path
			end

			files = ['others/info.yml', 'README.rdoc']
			files.each do | file |
				path = "modules/#{name}/#{file}"
				create_file(path) unless File.exist? path
			end
		end

		def isay str
			say str, "\e[33m"
		end

		def error msg
			say msg, "\e[31m"
			exit
		end

		#get/set the yaml file
		#
		# @name, string, the file path you need to load
		# @argv, array, the argv you want to set
		# @str, string, you want to show the word to the terminal
		# @custom, boolean, see the method SCFG.load
		def show_info name = nil, argv = 0, str = nil, custom = false
			SCFG.load(name, custom) if name != nil
			if argv.length > 0
				argv.each do | item |
					key, val = item.split(':')
					SCFG.set key, val 
				end
			end
			isay("========= #{str} ========= \n") unless str == nil
			SCFG.get.each do |k,v| isay "#{k.to_s} : #{v}" end
		end

		def get_file_num file_path, change_str = true
			suffix = file_path[-1] == '/' ? '*' : '/*'
			nums = Dir[file_path + suffix].length
			if change_str == true
				nums = nums.next
				nums.to_s.rjust(3, '0')
			end
		end

	end

end
