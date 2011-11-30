require 'sinatra'
require 'sequel'
require 'slim'

set :environment, 'development'
configure :development do

	set :home_page, '/index.html'

	#yum install sqlite3*
	#gem install sqlite3
	set :db_connect_sqlite, 'sqlite://db/data.db'

	#yum install postgres*
	#gem install pg
	#initdb -D db/pg
	#postgres -D db/pg
	#createdb db/pg
	set :db_connect_pg, 'postgres://localhost/db/pg'	

	#yum install mysql*
	#gem install mysql
	#/etc/init.d/mysqld start

	#create database and user
	#mysql -r root -p
	#create user 'myuser'@'localhost' identified by '123456';
	#create database mydb;
	#grant all privileges on *.* to 'myuser'@'localhost' with grant option;
	#granl all on mydb.* to 'myuser'@'localhost';
	#quit <enter>

	#change the password
	#mysql -u root -p
	#use mysql;
	#update user set password=PASSWORD("new-password") where User="myuser"
	set :db_connect_mysql, 'mysql://localhost/mydb?user=myuser&password=123456'	

	set :db_connect_memory, 'sqlite:/'

	#DB = Sequel.connect(settings.db_connect_sqlite)

	#setting for rackup
	disable :logging
end

get '/' do
	status, headers, body = call! env.merge("PATH_INFO" => settings.home_page)
end
