## 
# == Description
# read the config file that has the suffix with .cfg or .list
#
# == Arguments of SCFG.load
# :name, module name
# :path, specifying complete path
# :return, return the values
# :init, with the default values to initialize the basic option
# :current, load current options as the return values
# :type, a format type, by default, it is normal text, other is list

class SCFG

	@@options = {}
	@@changed = []
	@@path	  = 'Seimfile'

	class << self

		#load config to the @@options by @@path
		def load options = {}

			result = {}
			isload = false
			content = ""

			@@path = options[:path] if options.include? :path
			@@path = "modules/#{options[:name]}/#{Sbase::Files[:info]
}" if options.include? :name
			@@path = File.expand_path(@@path)
			isload = true if File.exist?(@@path)
			
			#the file type
			file_type = @@path.split(".").last.to_sym
			file_type = Sbase::File_type[0] unless Sbase::File_type.include? file_type

			#load from config file
			if options.include?(:current) and @@options.include?(@@path)
				result = @@options[@@path]
			elsif isload == true
				content << File.read(@@path)

				#list file
				if file_type == :list

					result = []
					content = content.strip

					if content.index("\n\n")
						content.split("\n\n").each do | lines |
							row = {}
							lines.split("\n").each do | line |
								unless line[0] == '"' and line.index("=")
									key, val = line.split("=")
									row[key] = val
								end
							end
							result << row unless row.empty?
						end
					else
						row = {}
						content.split("\n").each do | line |
							unless line[0] == '"' and line.index("=")
								key, val = line.split("=")
								row[key] = val
							end
						end
						result << row unless row.empty?
					end

				#cfg file
				elsif content.index("\n")
					content.split("\n").each do | line |
						unless line[0] == '"' and line.index("=")
							key,val = line.split("=")
							result[key] = val
						end
					end
				end

			end

			@@options[@@path] = {} unless @@options.include?(@@path)
			@@options[@@path] = result

			if options.include? :init
				init
			end

			#return the result
			if options.include? :return
				result 
			else
				isload
			end
		end

		def set key, val
			changed
			@@options[@@path][key.to_s] = val
		end

		def get key
			@@options[@@path].include?(key.to_s) ? @@options[@@path][key.to_s] : ''
		end

		def init name = :module
			Sbase::Infos[name].each do | key, val |
				set key, val
			end
		end

		def save
			unless @@changed.empty?
				@@changed.each do |path|
					content = ""
					@@options[path].each do | key, val |
						content << "#{key}=#{val}\n"
					end
					File.open(path, 'w+') do |f|
						f.write(content)
					end
				end
			end
		end

		def changed
			unless @@changed.include? @@path
				@@options[@@path]['changed'] = Time.now
				@@changed << @@path 
			end
		end

	end

end
