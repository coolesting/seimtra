require 'sinatra'
require 'sequel'
require 'slim'

HOMEPAGE 	= '/index'
DB_ENGINE 	= 0

ENV['DATABASE_URL'] = 'postgres://localhost/db/pg'

configure do
	DB = Sequel.connect(ENV['DATABASE_URL'])

	#setting for rackup
	disable :logging
end

get '/' do
	status, headers, body = call! env.merge("PATH_INFO" => HOMEPAGE)
end
