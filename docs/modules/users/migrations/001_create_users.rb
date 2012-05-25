Sequel.migration do
	change do
		create_table(:users) do
			primary_key :uid
			String :username, :fixed => true, :size => 20
			String :password, :fixed => true, :size => 50
			String :salt, :fixed => true, :size => 10
			Time :created
			Time :changed
			Integer :level, :size => 2, :default => 1
		end
	end
end
