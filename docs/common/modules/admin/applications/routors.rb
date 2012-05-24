get '/admin/modules' do
	@titile = 'the system modules'
	slim :modules
end

get '/admin/menus' do
	@titile = 'the system menus'
	@menus = DB[:menus]
	slim :menus
end

get '/admin/links' do
	@titile = 'the system links'
	@links = DB[:links]
	slim :links
end

get '/admin/settings' do
	@titile = 'the system settings'
	@settings = DB[:settings]
	slim :settings
end

get '/admin' do
	@titile = 'the back ground page'
	slim :admin
end
