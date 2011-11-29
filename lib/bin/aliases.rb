class SeimtraThor < Thor

	@@options = {}

	def self.sinit
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
		new_names.each do |k,v| map k => v.to_sym end
		@@options = new_names
	end

	desc "aliases", "Task aliases"
	def aliases
		@@options.each do |k,v| say "#{v} => #{k}", "\e[33m" end
	end

end
