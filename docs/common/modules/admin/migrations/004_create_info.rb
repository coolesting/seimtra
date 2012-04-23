Sequel.migration do
	change do
		create_table(:info) do
			Integer :mid
			String :ikey
			String :ival
		end
	end
end
