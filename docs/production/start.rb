require './environment'

#require SITEPATH + '/routes/index'
get '/' do
	@title = 'A seimtra application'
	@content = 'Welcome home!'
	slim :index
end

Dir[SITEPATH + '/routes/*.rb'].each do |route|
	require route
end
