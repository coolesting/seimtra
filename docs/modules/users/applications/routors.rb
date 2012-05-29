get '/users' do
	slim :users
end

get '/admin/users' do
	slim :users
end

get '/users/register' do
	slim :users_register
end

post '/users/register' do
end

get '/users/login' do
	slim :users_login
end

post '/users/login' do
end

