require File.expand_path('../lib/seimtra/info', __FILE__)
Gem::Specification.new do |s|
	s.name = "seimtra"
	s.date = "2011-10-13"
	s.version = Seimtra::Info::VERSION
	s.email = "coolesting@gmail.com"
	s.authors = ["bruce den coolesting"]
 	s.homepage = "http://github.com/coolesting/seimtra"
	s.description = "A web application based on sinatra, sequel, and slim."
  	s.summary = "A web application based on sinatra, sequel, and slim."

	s.executables = ['seimtra', '3s']
	s.default_executable = 'seimtra'
  	s.files = `git ls-files`.split("\n")
  	s.add_dependency 'sinatra'
  	s.add_dependency 'sequel'
  	s.add_dependency 'slim'
  	s.add_dependency 'thor'
end
