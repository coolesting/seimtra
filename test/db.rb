class Stest

	def check_column 
		name = ['bid', 'pid', 'books', 'plans', 'post']
		puts @db.check_column(name[0])
	end

	def autocomplete
		name = 'books'
		argv = ["String:name", "String:title"]
		puts @db.autocomplete(name, argv)
	end

	def columns
		puts @db.get_columns
	end

	def tables
		puts @db.get_tables
	end
end

