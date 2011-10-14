class Pro < Thor
	include Thor::Actions
	
	def self.source_root
		SPATH
	end

	desc "new project_name", "new a project with a name"
	def new(project_name = 'seimtra_project')
		directory 'doc', project_name
		puts "Initializing project successfully"
	end
end

