class SeimtraThor < Thor
	include Thor::Actions
	
	desc "new [NAME]", "Create a project with the name given"
	method_option :mode, :type => :string, :default => 'production', :aliases => '-m'
	def new(project_name = 'seimtra_project')
		directory 'docs/common', project_name
		SCFG.init
		SCFG.set 'log', 'off'
		SCFG.set 'log_path', Dir.pwd + '/log/default'
		SCFG.set 'module_focus', 'index'
		SCFG.set 'module_repository', File.expand_path('../SeimRepos', Dir.pwd)

		if options[:mode] == 'production'
			directory 'docs/production', project_name
			SCFG.set 'status', 'production'
			Dir.chdir(Dir.pwd + '/' + project_name)
			run("bundle install")
			say "Initializing complete.", "\e[32m"
		else
			directory 'docs/development', project_name
			SCFG.set 'status', 'development'
			Dir.chdir(Dir.pwd + '/' + project_name)
			say "Executing 'bundle install' for complete installation if this is your first time using the development editor", "\e[32m"
		end
	end

	desc "version", "The version of Seimtra"
	def version
		require 'seimtra/info'
		Seimtra::Info::constants(false).each do |name|
			say "#{name.to_s.downcase} : #{eval("Seimtra::Info::" + name.to_s)}", "\e[33m"
		end
	end

	desc "config", "Setting your global configuration"
	method_option :set, :type => :hash
	def config
		path, file = Stools.check_path
		run (file) unless File.exists?(File.expand_path(path))
		SCFG.load path, true

		#set config
		if options[:set] != nil 
			options[:set].each do |key,val|
				SCFG.set key, val 
			end
		end

		#get config
		SCFG.get.each do |k,v| say "#{k} : #{v}", "\e[33m" end
	end
end
