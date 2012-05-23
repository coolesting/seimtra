Sequel.migration do
	change do
		create_table(:modules) do
			primary_key :mid
			Integer :load_order
			String :module_name
			String :group_name
			String :opened
			String :status
			String :email
			String :author
			String :created
			String :version
			String :description
			String :dependon
		end
	end
end
