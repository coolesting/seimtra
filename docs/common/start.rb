require './environment'

set :views, Dir[settings.root + '/modules/*/templates']
helpers do
	def find_template(views, name, engine, &block)
		Array(views).each { |v| super(v, name, engine, &block) }
	end
end

Dir[settings.root + '/modules/*/application/*.rb'].each do |route|
	require route
end
