class Stest
	def g args = []
		require "seimtra/generator"
		g = Generator.new 'user'
		argv = []

		# Example 01, create a table
		#
		#	3s g table username:password:email
		#
		argv[0] = ['table', 'username:password:email']
	
		# Example 02, create a list 
		#
		# 	3s g list username:password:email
		#
		argv[1] = ['list', 'username:password:email']

		# Example 03, create a form 
		# 	
		# 	3s g form text:username pawd:password text:email 
		#
		argv[2] = ['form', 'text:username', 'pawd:password', 'text:email']

		# Example 04, create some routes
		#
		# 	3s g route get:login:logout post:login:register
		#
		argv[3] = ['route', 'get:login:logout', 'post:login:register']

		# Example 05, more details of this g usage
		# create a table, list, form once time
		#
		# 	3s g table username:password:email \ 
		# 	list username:password:email \
		# 	form text:username pawd:password text:email
		#
		argv[4] = ['table', 'username:password:email']
		argv[4] += ['list', 'username:password:email']
		argv[4] += ['form', 'text:username', 'pawd:password', 'text:email']
		
		argv[5] = ['userinfo']
		argv[5] += ['table', 'username:password:email']
		argv[5] += ['list', 'username:password:email']
		argv[5] += ['form', 'text:username', 'pawd:password', 'text:email']
		argv[5] += ['list', 'website:email']

		id = args.length > 0 ? args[0].to_i : 1
		g.run argv[id]
		puts g.output
	end
end
