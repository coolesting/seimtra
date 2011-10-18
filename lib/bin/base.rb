class SeimtraThor < Thor
	include Thor::Actions
	
	desc "init [NAME] [MODEL]", "Initialize your project with a name,
			default model is development"
	def init(project_name = 'seimtra_project', model = 'production')
		directory 'docs/common', project_name

		if model == 'production'
			directory 'docs/production', project_name
			Dir.chdir(Dir.pwd + '/' + project_name)
			run("bundle install")
		else
			directory 'docs/development', project_name
			say "Executing the command [bundle install] in your project directory if you need", "\e[32m"
		end

		say "Initializing complete!", "\e[32m"
	end

	desc "cleanup", "Cleanup local repository of the module"
	def cleanup(path = nil)
	end

	desc "list", "A list of local module"
	def list(path = nil)
	end
end

