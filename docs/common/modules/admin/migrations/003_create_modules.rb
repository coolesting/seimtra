Sequel.migration do
	change do
		create_table(:modules) do
			primary_key :mid
			String :module_name
		end
	end
end
