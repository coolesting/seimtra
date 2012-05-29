Sequel.migration do
	change do
		create_table(:links) do
			primary_key :lid
			Integer :bid
			String :name
			String :link
			String :description
			Integer :order, :size => 5, :default => 0
		end
	end
end
