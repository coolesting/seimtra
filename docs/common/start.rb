#
# please don't modify the file unless you know what are you doing.
require './environment'

L = {}
C = {}

templates = []
languages = ""
applications = []

def get_file file
	result = {}
	content = ''
	content << File.read(file) if File.exist? file
	if content.index("\n") and content.index("=")
		content.split("\n").each do | res |
			key,val = res.split("=")
			result[key] = val
		end
	end
	result
end

Dir[settings.root + "/modules/*/info.cfg"].each do | file |
	content = get_file file
	unless content.empty? and content.include?('name') 
		C[content['name']] = content 

		if content.include?('open') and content['open'] == "on"
			templates << settings.root + "/modules/#{content['name']}/templates"
			applications += Dir[settings.root + "/modules/#{content['name']}/applications/*.rb"]

			if content.include?('lang')
				lang = settings.root + "/modules/#{content['name']}/languages/#{content['lang']}.lang"
				if File.exist?(lang)
					languages << File.read(lang)
				end
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

languages.split("\n").each do | l |
	key, val = l.split("=", 2) if l.index("=")
	L[key] = val
end

applications.each do | routor |
	require routor
end
