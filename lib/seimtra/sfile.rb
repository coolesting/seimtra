# == Description
# read and write the key-value file, or hash array
# 
# == the format of file document
#
# Example 01, hash array file
#
# skey=my_key1
# sval=my_val1
# 
# skey=my_key2
# sval=my_val2
#
# Example 02, key-value file
#
# name=bruce dengx
# email=coolesting@gmail.com
# website=http://github.com/coolseting

class Sfile

	class << self

		# read the file to hash or array, return nil if the file is not existing
		def read path
			result = ""
			path = File.expand_path path

			if File.exist? path

				content = ''
				content << File.read(path)
				content = content.strip

				#a hash array
				if content.index "\n\n"

					result = []
					content.split("\n\n").each do | lines |
						row = {}
						lines.split("\n").each do | line |
							unless line[0] == '"' and line.index("=")
								key, val = line.split("=")
								row[key.to_sym] = val
							end
						end
						result << row unless row.empty?
					end

				#a hash
				elsif content.index "\n"

					result = {}
					content.split("\n").each do | line |
						unless line[0] == '"' and line.index("=")
							key, val = line.split("=")
							result[key.to_sym] = val
						end
					end

				#a single key-value
				elsif content.index "="

					result = {}
					unless content[0] == '"'
						key, val = content.split("=")
						result[key.to_sym] = val
					end

				end

			end

			result == "" ? nil : result
		end

		# == Description
		# save the file to specifying path
		#
		# == Arguments
		# content, an array, or hash
		# path, string, likes this modules/install/menu.sfile
		def write data, path
			content = ""
			file_type = data.class.to_s

			if file_type == 'Array'
				data.each do | line |
					line.each do | key, val |
						content << "#{key.to_s}=#{val}\n"
					end
					content << "\n"
				end

			elsif file_type == 'Hash'
				data.each do | key, val |
					content << "#{key.to_s}=#{val}\n"
				end
			end

			path = File.expand_path path
			File.open(path, 'w+') do |f|
				f.write content
			end
		end

	end

end
