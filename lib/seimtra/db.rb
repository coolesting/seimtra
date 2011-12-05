class Db

	attr_accessor :msg, :error

	def initialize(path = './environment.rb')
		@msg 	= ''
		@error 	= false
		epath = File.expand_path(path)
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
		#match a id
		i = 1
		while i
			id = ''
			i.times do |j| id += name[j] end
			i = check_column(id.to_sym) ? (i + 1) : 0
		end
		id += 'id'
		argv.unshift("primary_key:#{id}")

		#match time field
		argv << 'Time:created'
		argv << 'Time:changed'
		argv
	end

end
