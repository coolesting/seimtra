def db 
	db = Db.new
	name = 'bookmark'
	argv = ["String:name", "String:title"]

	puts db.check_column(name)
	puts db.autocomplete(name, argv)
end
