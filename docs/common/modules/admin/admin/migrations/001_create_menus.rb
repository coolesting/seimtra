Sequel.migration do
	change do
		create_table(:menus) do
			primary_key :mid
			String :name
			String :desciption
		end
		create_table(:links) do
			Integer :mid
			String :name
			String :link
			String :desciption
			Integer :order, :size => 5, :default => 0
		end
	end
end
