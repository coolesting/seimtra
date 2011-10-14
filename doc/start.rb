require './environment'

#require SITEPATH + '/routes/index'
get '/' do
	@title = 'blog'
	@post = DB[:posts].all
	@content = ''
	@post.each do |row|
		@content += '<br/>' + row[:body]
	end
	slim :index
end

get '/new' do
	@post = DB[:posts].insert(:body => 'new a post for this blog...')
	redirect '/'
end
