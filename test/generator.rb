class Stest
	def g
		require "seimtra/generator"
		g = Generator.new 'user'

		# Example 01, create a table
		#
		#	3s g table username:password:email
		#
		argv0 = ['table', 'username:password:email']
	
		# Example 02, create a list 
		#
		# 	3s g list username:password:email
		#
		argv1 = ['list', 'username:password:email']

		# Example 03, create a form 
		# 	
		# 	3s g form text:username pawd:password text:email 
		#
		argv2 = ['form', 'text:username', 'pawd:password', 'text:email']

		# Example 04, create some routes
		#
		# 	3s g route get:login:logout post:login:register
		#
		argv3 = ['route', 'get:login:logout', 'post:login:register']

		# Example 05, more details of this g usage
		# create a table, list, form once time
		#
		# 	3s g table username:password:email \ 
		# 	list username:password:email \
		# 	form text:username pawd:password text:email
		#
		argv4 = ['table', 'username:password:email']
		argv4 += ['list', 'username:password:email']
		argv4 += ['form', 'text:username', 'pawd:password', 'text:email']
		
		argv = argv2
		g.run argv
		puts g.output
	end
end
