Sequel.migration do
	change do
		create_table(:menus) do
			primary_key :mid
			String :name
			String :desciption
		end
	end
end
