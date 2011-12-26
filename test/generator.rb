class Stest
	def g
		require "seimtra/generator"
		options = {}
		options[:routes] = ['get:load', 'get:register']
		g = Generator.new 'user', 'user', options
	end
end
