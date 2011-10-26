DB.create_table?(:auth) do 
	primary_key	:aid
	String		:name
	String		:pawd
	String		:email
	Integer		:level
end

DB.create_table?(:lists) do 
	primary_key	:lid
	String		:name
end

DB.create_table?(:pages) do 
	primary_key	:pid
	String		:title
	String		:description
	Integer		:level
end

DB.create_table?(:posts) do 
	primary_key	:pid
	text		:body
	Integer		:aid
end

