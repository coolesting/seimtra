require 'sinatra'
require 'sequel'
require 'slim'

set :environment, 'production'

# Note: you must keep the settings.db_connect value available if you 
# need the database
configure :production do

	set :home_page, '/index.html'
	set :db_sqlite, 'sqlite://db/data.db'
	set :db_pg, 	'postgres://localhost/db/pg'	
	set :db_mysql, 	'mysql://localhost/mydb?user=myuser&password=123456'	
	set :db_memory, 'sqlite:/'
	set :db_connect, settings.db_memory

	DB = Sequel.connect(settings.db_connect)

	#set for rackup
	disable :logging
end

# rewrite the root route
# get '/' do
# 	status, headers, body = call! env.merge("PATH_INFO" => settings.home_page)
# end
