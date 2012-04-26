Sequel.migration do
	change do
		create_table(:infos) do
			Integer :mid
			String :ikey
			String :ival
		end
	end
end
