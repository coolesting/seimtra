require 'sinatra'
require 'sequel'
require 'slim'

set :environment, 'production'
configure :production do

	set :home_page, '/index.html'
	set :db_sqlite, 'sqlite://db/data.db'
	set :db_pg, 	'postgres://localhost/db/pg'	
	set :db_mysql, 	'mysql://localhost/mydb?user=myuser&password=123456'	
	set :db_memory, 'sqlite:/'
	set :db_connect, settings.db_connect

	DB = Sequel.connect(settings.db_connect)

	#setting for rackup
	disable :logging
end

get '/' do
	status, headers, body = call! env.merge("PATH_INFO" => settings.home_page)
end
