require 'sinatra'
require 'sequel'
require 'slim'

configure do

	set :home_page, '/index.html'
	set :db_sqlite, 'sqlite://db/data.db'
	set :db_pg, 	'postgres://localhost/db/pg'	
	set :db_mysql, 	'mysql://localhost/mydb?user=myuser&password=123456'	
	set :db_memory, 'sqlite:/'
	set :db_connect, settings.db_memory

	#change the db_connect that you want
	#if you not need the database, set the value :db_connect to 'closed'
	DB = Sequel.connect(settings.db_connect)

	#set for rackup
	disable :logging
end

# # rewrite the root route
# get '/' do
# 	status, headers, body = call! env.merge("path_info" => settings.home_page)
# end
