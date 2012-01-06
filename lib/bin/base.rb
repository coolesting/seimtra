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
			isay "Executing 'bundle install' for complete installation \
			if this is your first time using the development editor"
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

		def generate opt, argv
			empty_directory(Dir.pwd + '/modules') unless File.exist?(Dir.pwd + '/modules')
			require "seimtra/generator"

			module_current = options[:to] == nil ? SCFG.get(:module_focus) : options[:to]
			error(Utils.message) unless Utils.check_module(module_current)

			g = Generator.new module_current
			g.send("create_#{opt.to_s}", argv) if g.respond_to? "create_#{opt.to_s}"

			g.output
# 
# 			g.app_contents.each do |path, content|
# 				if File.exist? path
# 					prepend_to_file path, content
# 				else
# 					create_file path, content
# 				end
# 			end
# 
# 			g.tpl_contents.each do |path, content|
# 				create_file path, content
# 			end
		end

	end

end
