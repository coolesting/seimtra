require File.expand_path('../lib/seimtra/base', __FILE__)
Gem::Specification.new do |s|

	s.name 		= Seimtra::Base::Info[:name]
	s.date 		= Seimtra::Base::Info[:created]
	s.version 	= Seimtra::Base::Info[:version]
	s.email 	= Seimtra::Base::Info[:email]
	s.authors 	= Seimtra::Base::Info[:author]
 	s.homepage 	= Seimtra::Base::Info[:homepage]
	s.description = Seimtra::Base::Info[:description]
  	s.summary 	= Seimtra::Base::Info[:summary]


	s.executables = ['seimtra', '3s']
	s.default_executable = 'seimtra'
  	s.files = `git ls-files`.split("\n")
  	s.add_dependency 'sinatra'
  	s.add_dependency 'sequel'
  	s.add_dependency 'slim'
  	s.add_dependency 'thor'

end
