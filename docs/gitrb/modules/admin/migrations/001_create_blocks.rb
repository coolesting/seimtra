Sequel.migration do
	change do
		create_table(:blocks) do
			primary_key :bid
			Integer :mid
			String :name
			String :type
			String :description
			DateTime :created
		end
	end
end
