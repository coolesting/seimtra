class SeimtraThor < Thor

	desc 'test [NAME] [ARGV]', 'Make a test, and output the result'
	method_option :with, :type => :string, :aliases => '-w'
	method_option :focus, :type => :boolean, :aliases => '-f'
	map 't' => :test
	def test(func_name = nil, *argv)
		error("Enter your test name likes this, 3s test db") if func_name == nil
		require "seimtra/stest"
		Dir[ROOTPATH + "/test/*"].each do | file |
			require file
		end
		t = Stest.new
		error "The #{func_name} method is not existing." unless t.respond_to?(func_name)

		if argv.empty?
			t.send(func_name)
		else
			t.send(func_name, argv)
		end
	end

end
