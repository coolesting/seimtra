require 'sass'

configure do
	set :sass, :cache => true, :cahce_location => './tmp/sass-cache', :style => :compressed
end

get '/css/sass.css' do
	sass :index
end
