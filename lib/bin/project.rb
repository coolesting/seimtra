class SeimtraThor < Thor
	include Thor::Actions
	
	desc "init [project_name]", "initialize a project with a specific name"
	def init(project_name = 'seimtra_project')
		directory 'doc', project_name
		path =  Dir.pwd + '/' + project_name
		Dir.chdir(path)
		run("bundle install")
		puts "Initializing complete"
	end
end

