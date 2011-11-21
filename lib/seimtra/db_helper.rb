class Db_healer

	attr_accessor :msg, :error

	def initialize(path = '/environment.rb')
		@msg 	= ''
		@error 	= false
		epath = Dir.pwd + path
		if File.exist?(epath)
			require epath
		else
			@error 	= true
			@msg	= 'No such the file ' + epath
		end
	end
	
	#@name symbol
	def check_column(name)
		DB.tables.each do |table|
			DB[table.to_sym].columns!.each do |column|
				return true if name == column
			end
		end
		false
	end

	#@name string, a table name
	#@argv array, such as ['String:title', 'text:body']
	def autocomplete(name, argv)
	end

end
