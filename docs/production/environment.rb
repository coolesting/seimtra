SITEPATH = Dir.pwd
#require SITEPATH + '/lib/base.rb'

require 'sinatra'
require 'sequel'
require 'slim'

ENV['DATABASE_URL'] = 'postgres://localhost/db/pg'

configure do
	DB = Sequel.connect(ENV['DATABASE_URL'])

	#setting for rackup
	disable :logging
end
