class SeimtraThor < Thor
	include Thor::Actions
	
	desc "init [NAME]", "Create a project with the name given"
	method_option :status, :type => :string
	method_option :bundle, :type => :boolean
	map "new" => :init
	def init project_name = 'seimtra_project'
		directory 'docs/project', project_name
		Dir.chdir(Dir.pwd + '/' + project_name)

		all_status = ["development", "production", "test"]
		status = all_status.include?(options[:status]) ? options[:status] : "production"

# 		all_status.delete(status)
# 		without_status = all_status.join(" ")

		SCFG.load :path => "#{Dir.pwd}/Seimfile"
		SCFG.set :status, status
		SCFG.set :root_privilege, random_string
		Sbase::Project_info.each do | key, val |
			SCFG.set key, val
		end

 		install_modules = Sbase::Required_module
		bundler = options.bundle? ? " --bundler" : ""
		run "3s add " + install_modules.join(' ') + bundler
		isay "Initializing complete"
	end

	desc "version", "The version of Seimtra"
	map "v" => :version
	def version
		str = "Seimtra Information"
		show_info Sbase::Version, str
	end

end

class SeimtraThor < Thor

	no_tasks do

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
			curmod = name == nil ? SCFG.get(:module_focus) : name
			error("The module #{curmod} is not existing") unless module_exist? curmod 
			curmod
		end

		# get the customize info
		def get_custom_info 
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
			Sbase::Folders.values.each do | folder |
				path = "modules/#{name}/#{folder}"
				empty_directory(path) unless File.exist? path
			end

			Sbase::Files.values.each do | file |
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
			unless result.class.to_s == "Hash"
				say("The return values is not a Hash.") 
				exit
			end

			str = "\n"
			result.each do | key, val | 
				key = key.to_s + " "
				str += "#{key.ljust(20, '-')} #{val}\n"
			end
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

		def get_erb_content path
			require 'erb'
			path = ROOTPATH + "/" + path
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
