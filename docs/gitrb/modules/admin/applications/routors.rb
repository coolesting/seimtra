get '/admin/modules' do
	@title = 'the system modules'
	slim :modules
end

get '/admin/blocks' do
	opt_events :add, :remove, :alter
	@title = 'the system blocks'
	@blocks = DB[:blocks]
	slim :blocks
end

get '/admin/links' do
	@title = 'the system links'
	@links = DB[:links]
	slim :links
end

get '/admin/settings' do
	@title = 'the system settings'
	@settings = DB[:settings]
	slim :settings
end

get '/admin' do
	@title = 'the back ground page'
	slim :admin
end
