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
		# 	3s view operator:name argv1 argv2 argv3
		#
		# the operator could be table, list, form, and the name you could give it what 
		# you need, by default, the name will be table1, list1 if no name given.
		#
		# Example 01
		# create a table with the existing fields of current database
		#
		#	3s view table username:password:email
		#	3s view table:userinfo username:password:email
		#
		argv1 = ['table:userinfo', 'username:password:email']
	
		# Example 02
		# list the fields, 
		#
		# 	3s view list:listinfo username:password:email
		#
		argv2 = ['list:listinfo', 'username:password:email']

		# Example 03
		# create a form for adding the user data
		# 	
		# 	3s view form:adduser text:username pawd:password text:email
		#
		argv3 = ['form:adduser', 'text:username', 'pawd:password', 'text:email']

		# Example 04
		# you can create all of examples above once time
		#
		# 	3s view table username:password:email \ 
		# 	list username:password:email \
		# 	form text:username pawd:password text:email
		#
		argv4 = []
		
		g.create_view argv1

		puts g.app_contents
		puts g.tpl_contents
	end
end
