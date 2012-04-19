# please don't modify the file unless you know what are you doing.
require 'seimtra/info'
require './environment'
require './lib'

templates = []
languages = ""
applications = []

#module info
I = {}

#get the info from local file
if settings.db_connect == "closed"
	Dir[settings.root + "/modules/*/" + Seimtra::File::INFO].each do | file |
		content = get_file file
		unless content.empty? and content.include?('name') and content.include?('open') and content['open'] == "on"
			I[content['name']] = content 
		end
	end

#enable the database
else
	info = DB[:info]
	modules = M = DB[:modules]

	infos = {}
	info.each do | row |
		infos[row[:mid]] = {row[:ikey] => row[:ival]}
	end
	modules.each do | row |
		I[row[:module_name]] = infos[row[:mid]]
	end
end

if I.empty?
	puts "The module info can not be empty."
	exit
end

I.each do | name, content |
	#preprocess the templates loaded item
	templates << settings.root + "/modules/#{name}/templates"

	#preprocess the applications loaded routors
	applications += Dir[settings.root + "/modules/#{name}/applications/*.rb"]

	#preprocess the language loaded packets
	language = content.include?('lang') ? content['lang'] : "en"
	path = settings.root + "/modules/#{name}/languages/#{language}.lang"
	languages << File.read(path) if File.exist?(path)
end

set :views, templates
helpers do
	def find_template(views, name, engine, &block)
		Array(views).each { |v| super(v, name, engine, &block) }
	end
end

class Languages; end
L = Languages.new
languages.split("\n").each do | line |
	key, val = line.split("=", 2) if line.index("=")
	str = "def L.#{key}; '#{val}' end"
	eval str
end

applications.each do | routor |
	require routor
end
