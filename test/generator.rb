class Stest

	def g args = []

		argv = []

		# Example 01, create a table
		#
		#	3s g table username:password:email
		#
		argv[1] = ['table', 'username:password:email']
	
		# Example 02, create a list 
		#
		# 	3s g list username:password:email
		#
		argv[2] = ['list', 'username,password,email']

		# Example 03, create a form 
		# 	
		# 	3s g form text:username pawd:password text:email 
		#
		argv[3] = ['form', 'text:username', 'pawd:password', 'text:email']
		argv[31] = ['form', 'text:username', 'pawd:password', 'text:email', 'tpl_name:login']
		argv[32] = ['form', 'text:name', 'pawd:password', 'select:catalog:apple,banana,pipi']
		argv[33] = ['form', 'text:name', 'select:catalog:yml:files/data.yml']

		# Example 04, create some routes
		#
		# 	3s g route get;login post;login
		#
		argv[4] = ['route', 'get;login', 'post;login']

		# Example 05, more details of this g usage
		# create a table, list, form once time
		#
		# 	3s g table username:password:email \ 
		# 	list username:password:email \
		# 	form text:username pawd:password text:email
		#
		argv[5] = ['table', 'username:password:email']
		argv[5] += ['list', 'username:password:email']
		argv[5] += ['form', 'text:username', 'pawd:password', 'text:email']
		
		argv[51] = ['userinfo']
		argv[51] += ['table', 'username:password:email']
		argv[51] += ['list', 'username:password:email']
		argv[51] += ['form', 'text:username', 'pawd:password', 'text:email']
		argv[51] += ['list', 'website:email']

		require "seimtra/generator"
		g = Generator.new 'front'

		id = args.length > 0 ? args[0].to_i : 1
		g.run argv[id]
		p g.output 5
# 		result = g.output 3
# 		result.each do | k,v |
# 			puts "#{k} => #{v}"
# 		end
	end

end
