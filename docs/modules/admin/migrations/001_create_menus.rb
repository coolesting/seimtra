Sequel.migration do
	change do
		create_table(:menus) do
			primary_key :id
			Integer :mid
			String :name
			String :description
		end
	end
end
