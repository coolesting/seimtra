class SeimtraThor < Thor
	include Thor::Actions
	
	desc "project_create [NAME]", "create a project with the name given"
	method_options :dev => :boolean
	def project_create(project_name = 'seimtra_project')
		directory 'docs/common', project_name
		SCFG.set 'created', Time.now
		SCFG.set 'changed', Time.now

		unless options.dev?
			directory 'docs/production', project_name
			SCFG.set 'status', 'production'
			Dir.chdir(Dir.pwd + '/' + project_name)
			SCFG.install
			run("bundle install")
			say "Initializing complete.", "\e[32m"
		else
			directory 'docs/development', project_name
			SCFG.set 'status', 'development'
			Dir.chdir(Dir.pwd + '/' + project_name)
			SCFG.install
			say "Executing 'bundle install' for complete installation if this is your first time using the development editor", "\e[32m"
		end
	end

	desc "info", "The information of Seimtra"
	def info
		require 'seimtra/info'
		Seimtra::Info::constants(false).each do |name|
			say "#{name.to_s.downcase} : #{eval("Seimtra::Info::" + name.to_s)}", "\e[33m"
		end
	end
end
