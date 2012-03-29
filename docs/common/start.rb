#
# please don't modify the file unless you know what are you doing.
require './environment'

L = {}
C = {}
templates = []
applications = []

Dir[settings.root + "/modules/*/others/info.yml"].each do | file |
    content = YAML.load_file file
	if content.class.to_s == 'Hash' and content.include?('name') 
		C[content['name']] = content 

		if content.include?('open') and content['open'] == true
			templates << settings.root + "/modules/#{content['name']}/templates"
			applications += Dir[settings.root + "/modules/#{content['name']}/applications/*.rb"]

			if content.include?('lang')
				lang = settings.root + "/modules/#{content['name']}/languages/#{content['name']}.rb"
				applications << lang if File.exist?(lang)
			end
		end

	end
end

set :views, templates
helpers do
	def find_template(views, name, engine, &block)
		Array(views).each { |v| super(v, name, engine, &block) }
	end
end

applications.each do |routor|
	require routor
end
