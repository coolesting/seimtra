SITEPATH = Dir.pwd
#require SITEPATH + '/lib/base.rb'

require 'seimtra'

configure do
	#initdb -D db/pg
	#postgres -D db/pg
	#createdb db/pg
	DB = Sequel.connect(ENV['DATABASE_URL'] || 'postgres://localhost/db/pg')
	#DB = Sequel.connect(ENV['DATABASE_URL'] || 'postgres://localhost/db/pg?user=zcdny&password=745296')

	#create table
	DB.create_table?(:posts) do 
		primary_key	:pid
		text		:body
	end

	#setting for rackup
	disable :logging
end
