#set the specific template for admin view
before '/admin*'
	set :slim, :layout => :admin_layout
end

#filter the routes of module that you don't want to use
configure do
	Disable_routes = []
end

