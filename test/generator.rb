class Stest
	def g
		require "seimtra/generator"
		options = {}

		# test routes
# 		options[:routes] = ['get:load', 'get:register']

		# test view
		options[:view] = ['username', 'email']

		g = Generator.new 'user', 'user', options
	end
end
