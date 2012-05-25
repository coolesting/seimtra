Sequel.migration do
	change do
		create_table(:settings) do
			Integer :mid
			String :skey
			String :sval
		end
	end
end
