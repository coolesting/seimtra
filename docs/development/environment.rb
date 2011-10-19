SITEPATH = Dir.pwd

require 'sinatra'
require 'sequel'
require 'slim'

DB_ENGINE = 0
ENV['DATABASE_URL'] = case DB_ENGINE 
	#yum install sqlite3*
	#gem install sqlite3
	when 0
	'sqlite://db/data.db'

	#yum install postgres*
	#gem install pg
	#initdb -D db/pg
	#postgres -D db/pg
	#createdb db/pg
	when 1
	'postgres://localhost/db/pg'	

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
	when 2
	'mysql://localhost/mydb?user=myuser&password=123456'	

	#a memory database
	else
	'sqlite:/'
end

configure do
	DB = Sequel.connect(ENV['DATABASE_URL'])

	#setting for rackup
	disable :logging
end
