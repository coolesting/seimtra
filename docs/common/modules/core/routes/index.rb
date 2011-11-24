
get '/index' do
	@titile = 'the defalut page'
	slim :index
end

get '/admin' do
	@titile = 'the admin page'
	slim :admin, :layout => :admin_layout
end
