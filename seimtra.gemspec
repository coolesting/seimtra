require File.expand_path('../lib/seimtra/info', __FILE__)
Gem::Specification.new do |s|
	s.name 		= Seimtra::Info::NAME
	s.date 		= Seimtra::Info::DATE
	s.version 	= Seimtra::Info::VERSION
	s.email 	= "coolesting@gmail.com"
	s.authors 	= Seimtra::Info::AUTHORS
 	s.homepage 	= "http://github.com/coolesting/seimtra"
	s.description = Seimtra::Info::DESCRIPTION
  	s.summary 	= Seimtra::Info::SUMMARY


	s.executables = ['seimtra', '3s']
	s.default_executable = 'seimtra'
  	s.files = `git ls-files`.split("\n")
  	s.add_dependency 'sinatra'
  	s.add_dependency 'sequel'
  	s.add_dependency 'slim'
  	s.add_dependency 'thor'
end
