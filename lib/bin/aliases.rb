class SeimtraThor < Thor
	map "m" => :migrate
	map "s" => :schema

	desc "alias", "See the alias of task name"
	def alias
		puts "the alias"
	end
end
