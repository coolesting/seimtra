Sequel.migration do
	change do
		create_table(:links) do
			Integer :mid
			String :name
			String :link
			String :description
			Integer :order, :size => 5, :default => 0
		end
	end
end
