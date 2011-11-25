get '/admin' do
	@titile = 'the admin page'
	slim :admin, :layout => :admin_layout
end
