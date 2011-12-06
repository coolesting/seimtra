class Stest

	attr_accessor :error, :msg

	def initialize(func_name)

		@error		= false
		@msg		= ''
		@func_name 	= func_name
		@db 		= Db.new

		@msg = "No #{@func_name} method of Stest class" unless respond_to?(@func_name)
		@error = true if @msg != ''
		send(@func_name)

	end

end
