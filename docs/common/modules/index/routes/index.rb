before do
	cache_control :css_sass, :must_revalidate, :max_age => 10000
end

get '/css/sass' do
	cache_control :css_sass
	sass :index, :cache => true, :cahce_location => './tmp/sass-cache', :style => :compressed
end

get '/index' do
	@titile = 'the defalut page'
	slim :index
end

get '/admin' do
	@titile = 'the admin page'
	slim :admin, :layout => :admin_layout
end
