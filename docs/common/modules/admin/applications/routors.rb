get '/admin/modules' do
end

get '/admin/menus' do
end

get '/admin/links' do
end

get '/admin/settings' do
end

get '/admin' do
	@titile = 'the back ground page'
	slim :admin
end
