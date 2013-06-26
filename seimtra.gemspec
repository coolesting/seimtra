require File.expand_path('../lib/seimtra/sbase', __FILE__)
Gem::Specification.new do |s|

	s.name 		= Seimtra::Sbase::Version[:name]
	s.date 		= Seimtra::Sbase::Version[:created]
	s.version 	= Seimtra::Sbase::Version[:version]
	s.email 	= Seimtra::Sbase::Version[:email]
	s.authors 	= Seimtra::Sbase::Version[:author]
 	s.homepage 	= Seimtra::Sbase::Version[:homepage]
	s.description = Seimtra::Sbase::Version[:description]
  	s.summary 	= Seimtra::Sbase::Version[:summary]


	s.executables = ['seimtra', '3s']
	s.default_executable = 'seimtra'
  	s.files = `git ls-files`.split("\n")
  	s.add_dependency 'thor'

end
