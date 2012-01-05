class Stest
	def g
		require "seimtra/generator"
		g = Generator.new 'user'
	end
	
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
		# Example 01
		# create a table with the existing fields of current database
		#
		#	3s view table username:password:email
		#
		# or
		#
		# 	3s view username:password:email
		#
		# by default, the operator is a table
		#
		# 	3s view [operator] field_name1:field_name2:field_name3
		# 	3s view [table|list|form] field_name1:field_name2:field_name3
		#
		argv1 = ['table', 'username:password:email']
		argv2 = ['username:password:email']
	
		# Example 02
		# list the fields, 
		#
		# 	3s view list username:password:email
		#
		argv3 = ['list', 'username:password:email']

		# Example 03
		# create a form for adding the user data
		# 	
		# 	3s view form text:username pawd:password text:email
		#
		argv4 = ['form', 'text:username', 'pawd:password', 'text:email']

		# Example 04
		# you can create all of examples above once time
		#
		# 	3s view username:password:email list username:password:email form text:username pawd:password text:email
		#
		
		g.create_view argv1

		puts g.app_contents
		puts g.tpl_contents
	end
end
