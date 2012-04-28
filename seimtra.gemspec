require File.expand_path('../lib/seimtra/base', __FILE__)
Gem::Specification.new do |s|

	s.name 		= Seimtra::Base::Version[:name]
	s.date 		= Seimtra::Base::Version[:created]
	s.version 	= Seimtra::Base::Version[:version]
	s.email 	= Seimtra::Base::Version[:email]
	s.authors 	= Seimtra::Base::Version[:author]
 	s.homepage 	= Seimtra::Base::Version[:homepage]
	s.description = Seimtra::Base::Version[:description]
  	s.summary 	= Seimtra::Base::Version[:summary]


	s.executables = ['seimtra', '3s']
	s.default_executable = 'seimtra'
  	s.files = `git ls-files`.split("\n")
  	s.add_dependency 'sinatra'
  	s.add_dependency 'sequel'
  	s.add_dependency 'slim'
  	s.add_dependency 'thor'

end
