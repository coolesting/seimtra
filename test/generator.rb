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

		g.output
	end
end
