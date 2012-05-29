require 'sinatra'
require 'sequel'
require 'slim'

configure do

	## 
	# mysql
	#
	#	yum install mysql*
	#	gem install mysql
	#	/etc/init.d/mysqld start
	#
	# create database and user
	#
	#	mysql -r root -p
	#	create user 'myuser'@'localhost' identified by '123456';
	#	create database mydb;
	#	grant all privileges on *.* to 'myuser'@'localhost' with grant option;
	#	granl all on mydb.* to 'myuser'@'localhost';
	#	quit
	#
	# change the password
	#
	#	mysql -u root -p
	#	use mysql;
	#	update user set password=PASSWORD("new-password") where User="myuser"
	set :db_mysql, 'mysql://localhost/mydb?user=myuser&password=123456'	

	set :db_memory, 'sqlite:/'

	##
	# postgresql
	#
	#	yum install postgres*
	#	gem install pg
	#	initdb -D db/pg
	#	postgres -D db/pg
	#	createdb db/pg
	set :db_pg, 'postgres://localhost/db/pg'	

	##
	# sqlite
	#
	#	yum install sqlite3*
	#	gem install sqlite3
	set :db_sqlite, 'sqlite://db/data.db'

	#change the db_connect that you want
	#if you not need the database, set the value as 'closed'
	set :db_connect, settings.db_sqlite

	DB = Sequel.connect(settings.db_connect)

	#set for rackup
	disable :logging

	#define the home page
	set :home_page, '/index.html'

	set :cache_static_file, false
end

# get '/' do
# 	status, headers, body = call! env.merge("PATH_INFO" => settings.home_page)
# end
