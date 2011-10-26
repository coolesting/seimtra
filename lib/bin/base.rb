class SeimtraThor < Thor
	include Thor::Actions
	
	desc "init [NAME] [MODEL]", "Initialize your project with a name,
			default model is development"
	def init(project_name = 'seimtra_project', model = 'production')
		directory 'docs/common', project_name
		SCFG.set 'created', Time.now
		SCFG.set 'changed', Time.now

		SCFG.install
		if model == 'production'
			directory 'docs/production', project_name
			SCFG.set 'status', 'production'
			Dir.chdir(Dir.pwd + '/' + project_name)
			run("bundle install")
		else
			directory 'docs/development', project_name
			SCFG.set 'status', 'development'
			Dir.chdir(Dir.pwd + '/' + project_name)
			say "Executing 'bundle install' if you need", "\e[32m"
		end

		say "Initializing complete.", "\e[32m"
	end

	desc "clean [OPTION]", "Clean something beasd on option that maybe is the module, log, or migration"
	def clean(option = nil)
	end

	desc "list", "A list of local module"
	def list(path = nil)
	end

	desc "log", "A list of log"
	def log
	end

	desc "config", "The Seimfile configuration file"
	def config
		SCFG.show
	end
end
