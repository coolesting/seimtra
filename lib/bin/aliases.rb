class SeimtraThor < Thor
	desc "task_alias", "See the alias name of task"
	def task_alias(output = true)
		old_names = SeimtraThor.instance_methods(false)
		new_names = {}

		i = 1; 
		old_names.each do |name|
			key_name = ''
			name.to_s.split('_').each do |subname| key_name << subname[0] end
			begin
				raise if new_names.has_key? key_name
				new_names[key_name] = name
			rescue
				i++
				j = i
				key_name += j.to_s
				retry
			end
		end

		if output == true
			new_names.each do |k,v| puts "#{v} => #{k}" end
		else
			new_names.each do |k,v| map k => v.to_sym end
		end
	end
end
