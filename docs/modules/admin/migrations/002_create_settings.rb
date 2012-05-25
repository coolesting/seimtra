Sequel.migration do
	change do
		create_table(:settings) do
			primary_key :id
			Integer :mid
			String :skey
			String :sval
		end
	end
end
