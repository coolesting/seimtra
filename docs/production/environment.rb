require 'sinatra'
require 'sequel'
require 'slim'

set :environment, 'production'
configure :production do

	set :home_page, '/index.html'
	set :db_connect_sqlite, 'sqlite://db/data.db'
	set :db_connect_pg, 'postgres://localhost/db/pg'	
	set :db_connect_mysql, 'mysql://localhost/mydb?user=myuser&password=123456'	
	set :db_connect_memory, 'sqlite:/'

	#DB = Sequel.connect(settings.db_connect_sqlite)
	#setting for rackup
	disable :logging
end

get '/' do
	status, headers, body = call! env.merge("PATH_INFO" => settings.home_page)
end
