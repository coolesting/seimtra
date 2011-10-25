require './environment'

set :views, Dir[SITEPATH + '/modules/*/views']
helpers do
	def find_template(views, name, engine, &block)
		Array(views).each { |v| super(v, name, engine, &block) }
	end
end

get '/' do
	@title = 'A seimtra application'
	@content = 'Welcome home!'
	slim :index
end

Dir[SITEPATH + '/modules/*/routes/*.rb'].each do |route|
	require route
end
