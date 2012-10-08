class Stest
	
	def slim
		require "slim"
		Tilt.new['template.slim'].render(scope)
		Slim::Template.new(filename, optional_option_hash).render(scope)
		Slim::Template.new(optional_option_hash) { source }.render(scope)
	end

end
