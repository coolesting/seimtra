class SeimtraThor < Thor
	include Thor::Actions

	long_desc <<-DOC
	== Description

	create a new project

	== Example

	3s init project_name
	DOC

	desc "init [NAME]", "Create a project with the name given"
	method_option :status, :type => :string
	def init project_name = 'seimtra_project'
		#check the config file of customization
		config_path
		
		#get the docs
		if File.exists?(Sbase::Paths[:docs_local] + "/config.ru")
			directory Sbase::Paths[:docs_local], project_name
		else
			run "git clone #{Sbase::Paths[:docs_remote]} #{project_name}"
		end

		#write the docs
		Dir.chdir(Dir.pwd + '/' + project_name)

		#set the project info
		spath = "#{Dir.pwd}/#{Sbase::Files_root[:seimfile]}"
		seimfile = Sfile.read spath
		seimfile[:status] = options[:status] if Sbase::Status_type.include?(options[:status])
		seimfile[:root_privilege] = random_string
		Sbase::Infos[:project].each do | key, val |
			seimfile[key] = val
		end
		Sfile.write seimfile, spath

		#install bundle gem
		if `gem list`.index('bundler ') == nil
			run 'gem install bundler'
			run "bundle install --gemfile=modules/system/Gemfile"
		end

		#install modules
		run "3s install "
		isay "The project Initializes completely"
	end

	long_desc <<-DOC
	== Description

	see the version of seimtra

	== Example

	3s version

	3s v
	DOC

	desc "version", "The version of Seimtra"
	map "v" => :version
	def version
		str = "Seimtra Information"
		show_info Sbase::Version, str
	end

end

class SeimtraThor < Thor

	no_tasks do

		#get content of Seimfile
		def project_config
			Sfile.read "#{Dir.pwd}/#{Sbase::Files_root[:seimfile]}"
		end

		#return a random string with the size given
		def random_string size = 12
			charset = ('a'..'z').to_a + ('0'..'9').to_a + ('A'..'Z').to_a
			(0...size).map{ charset.to_a[rand(charset.size)]}.join
		end

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
		def get_module name = nil
			curmod = name == nil ? get_default_module : name
			error("The module #{curmod} is not existing") unless module_exist? curmod 
			curmod
		end

		def get_default_module
			project_config[:module_focus]
		end

		# get the customize info
		# write it if the file is not existing
		def config_path write = false
			path = Dir.pwd
			#windows
			if /\w:\\?/.match(path)
				path = Sbase::Paths[:config_ms]
				file = "echo '' > #{path}"
			#linux
			else
				path = Sbase::Paths[:config_lx]
				file = "touch #{path}"
			end

			unless File.exist? path
				system file
			end
			path
		end

		def blank? var
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

		#generate the requried file
		def module_init name
			Sbase::Folders.values.each do | folder |
				path = "modules/#{name}/#{folder}"
				empty_directory(path) unless File.exist? path
			end

			Sbase::Files.values.each do | file |
				path = "modules/#{name}/#{file}"
				create_file(path) unless File.exist? path
			end

			Sbase::File_install.values.each do | file |
				path = "modules/#{name}/#{file}"
				create_file(path) unless File.exist? path
			end

			Dir.chdir(Dir.pwd)
		end

		def isay str
			say str, "\e[33m"
		end

		def error str
			say str, "\e[31m"
			exit
		end

		def show_info result, title = "Current info"
			isay "\n" + "="*50
			isay title.center(50, " ") + "\n"
			isay "="*50

			str = ""
			if result.class.to_s == "Hash"
				result.each do | key, val | 
					key = key.to_s + " "
					str += "\n#{key.ljust(20, '-')} #{val}"
				end
			elsif result.class.to_s == "Array"
				result.each do | item | 
					str += "\n" + item.to_s
				end
			else
				str += str
			end
			
			str += "\n"
			isay str
		end

		def get_file_num file_path, change_str = true
			suffix = file_path[-1] == '/' ? '*' : '/*'
			nums = Dir[file_path + suffix].length
			if change_str == true
				nums = nums.next
				nums.to_s.rjust(3, '0')
			end
		end

		def get_erb_content path, relative = true
			require 'erb'
			path = ROOTPATH + "/" + path if relative == true

			if File.exist? path
				content = File.read(path)
				t = ERB.new(content)
				t.result(binding)
			else
				"No such the file at #{path}" 
			end
		end

	end

end
