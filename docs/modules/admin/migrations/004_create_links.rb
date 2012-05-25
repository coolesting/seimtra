Sequel.migration do
	change do
		create_table(:links) do
			primary_key :id
			Integer :mid
			Integer :menu_id
			String :name
			String :link
			String :description
			Integer :order, :size => 5, :default => 0
		end
	end
end
