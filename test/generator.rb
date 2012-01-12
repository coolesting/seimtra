class Stest
	def route
		require "seimtra/generator"
		g = Generator.new 'user'

		#get content from customize
# 		g.create_route ['get:login:register:logout', 'post:login']

		#get content from template
		g.create_route ['new', 'edit'], true

		puts g.app_contents
	end

	def view
		require "seimtra/generator"
		g = Generator.new 'user'

		# Example about the '3s view' command
		#
		# 	3s view [route_name] [style:type] argv1 argv2 argv3
		#
		# if the route_name is ignored, that will be null
		# the type of style could be the table, list, form, by default, it will be table
		#
		# Example 01
		# create a table with the existing fields of current database
		#
		#	3s view username:password:email
		#	3s view info username:password:email style:table 
		#	3s view info username:password:email
		#
		argv0 = ['username:password:email']
		argv1 = ['info', 'style:table', 'username:password:email']
	
		# Example 02
		# list the fields, 
		#
		# 	3s view list username:password:email style:list 
		#
		argv2 = ['list', 'style:list', 'username:password:email']

		# Example 03
		# create a form for adding the user data
		# 	
		# 	3s view edit text:username pawd:password text:email -n=edit
		#
		argv3 = ['form', 'text:username', 'pawd:password', 'text:email']

		# Example 04
		# you can create all of examples above once time
		#
		# 	3s view username:password:email \ 
		# 	list username:password:email \
		# 	form text:username pawd:password text:email
		#
		argv4 = ['username:password','list', 'username:email', \
		'form', 'text:username', 'pawd:password', 'text:email']
		
		argv = argv2

		argv.unshift 'userinfo'
		g.create_view argv

		puts g.app_contents
		puts g.tpl_contents
	end
end
