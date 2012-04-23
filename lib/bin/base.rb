class SeimtraThor < Thor
	include Thor::Actions
	
	desc "init [NAME]", "Create a project with the name given"
	method_option :dev, :type => :boolean
	def init project_name = 'seimtra_project'
		directory 'docs/common', project_name
		unless options.dev?
			directory 'docs/production', project_name
			Dir.chdir(Dir.pwd + '/' + project_name)
			status = "production"
			run("bundle install")
			isay "Initializing complete."
		else
			directory 'docs/development', project_name
			Dir.chdir(Dir.pwd + '/' + project_name)
			status = "development"
			isay "Using 'bundle install' command for Binding the Gem applications, if you use the initializing command fisrt time"
		end

		SCFG.load :path => "#{Dir.pwd}/Seimfile", :init => true
		SCFG.set :status, status
		SCFG.set :log, SCFG::OPTIONS[:log]
		SCFG.set :log_path, SCFG::OPTIONS[:log_path]
		SCFG.set :module_focus, SCFG::OPTIONS[:module_focus]
		SCFG.set :module_repository, SCFG::OPTIONS[:module_repos]
		
 		install_modules = ["admin", "front", "users"]
		run "3s install " + install_modules.join(' ')
	end

	desc "version", "The version of Seimtra"
	def version
		require 'seimtra/info'
		Seimtra::Info::constants(false).each do |name|
			isay "#{name.to_s.downcase} : #{eval("Seimtra::Info::" + name.to_s)}"
		end
	end

end

class SeimtraThor < Thor

	#build-in method of the class
	no_tasks do

		# return ture if the module is existing
		def module_exist? name, path = false
			if path == true
				return true if File.exist? name
			else
				Dir['modules/*'].each do | module_name |
					m = module_name.split('/').last
					return true if m == name
				end
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

		#generate the needs file
		def module_init name
			Seimtra::Base::Folders.values.each do | folder |
				path = "modules/#{name}/#{folder}"
				empty_directory(path) unless File.exist? path
			end

			Seimtra::Base::Files.values.each do | file |
				path = "modules/#{name}/#{file}"
				create_file(path) unless File.exist? path
			end
			Dir.chdir(Dir.pwd)
		end

		def isay str
			say str, "\e[33m"
		end

		def error msg
			say msg, "\e[31m"
			exit
		end

		def show_info result, title = "Current info"
			isay("========= #{title} ========= \n")
			unless result.class.to_s == "Hash"
				say("The return values is not a Hash in function show_info") 
				exit
			end
			result.each do |k,v| 
				isay "#{k.to_s} : #{v}"
			end
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
