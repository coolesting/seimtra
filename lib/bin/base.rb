class SeimtraThor < Thor
	include Thor::Actions
	
	desc "init [NAME]", "Create a project with the name given"
	method_option :status, :type => :string
	method_option :bundle, :type => :boolean
	def init project_name = 'seimtra_project'
		directory 'docs', project_name
		Dir.chdir(Dir.pwd + '/' + project_name)

		all_status = ["development", "production", "test"]
		status = all_status.include?(options[:status]) ? options[:status] : "production"

# 		all_status.delete(status)
# 		without_status = all_status.join(" ")

		SCFG.load :path => "#{Dir.pwd}/Seimfile"
		SCFG.set :status, status
		SCFG.set :root_privilege, random_string
		Sbase::Project_info.each do | key, val |
			SCFG.set key, val
		end

 		install_modules = Sbase::Required_module
		bundler = options.bundle? ? " --bundler" : ""
		run "3s add " + install_modules.join(' ') + bundler
		isay "Initializing complete"
	end

	desc "version", "The version of Seimtra"
	def version
		str = "Seimtra Information"
		show_info Sbase::Version, str
	end

end

class SeimtraThor < Thor

	#build-in method of the class
	no_tasks do

		#return a random string with the size given
		def random_string size = 12
			charset = ('a'..'z').to_a + ('0'..'9').to_a + ('A'..'Z').to_a
			(0...size).map{ charset.to_a[rand(charset.size)]}.join
		end

		# return ture if the module is existing
		def module_exist? name, path = false
			if path == true
				return true if File.exist? name
			else
				Dir['modules/*'].each do | module_name |
					m = module_name.split('/').last
					return true if m == name
				end
			end
			false
		end

		# return the real module name, others is default module in config file
		def get_module name
			curmod = name == nil ? SCFG.get(:module_focus) : name
			error("The module #{curmod} is not existing") unless module_exist? curmod 
			curmod
		end

		# get the customize info
		def get_custom_info 
			path = Dir.pwd
			#windows
			if /\w:\\?/.match(path)
				path = 'c:\.Seimtra'
				file = 'echo '' > C:\.Semitra'
			#others
			else
				path = '~/.Seimtra'
				file = 'touch ~/.Seimtra'
			end
			[path,file]
		end

		def blank?(var)
			return true if var == nil

			type = var.class
			if type == 'Fixnum' or type == 'Float' or type == 'Numeric'
				return true if var.zero?
			end
			if type == 'String' or type == 'Array' or type == 'Hash'
				return true if var.empty?
			end

			false
		end

		#generate the needs file
		def module_init name
			Sbase::Folders.values.each do | folder |
				path = "modules/#{name}/#{folder}"
				empty_directory(path) unless File.exist? path
			end

			Sbase::Files.values.each do | file |
				path = "modules/#{name}/#{file}"
				create_file(path) unless File.exist? path
			end
			Dir.chdir(Dir.pwd)
		end

		def isay str
			say str, "\e[33m"
		end

		def error str
			say str, "\e[31m"
			exit
		end

		def show_info result, title = "Current info"
			isay "\n" + "="*50
			isay title.center(50, " ") + "\n"
			isay "="*50
			unless result.class.to_s == "Hash"
				say("The return values is not a Hash.") 
				exit
			end

			str = "\n"
			result.each do | key, val | 
				key = key.to_s + " "
				str += "#{key.ljust(20, '-')} #{val}\n"
			end
			isay str
		end

		def get_file_num file_path, change_str = true
			suffix = file_path[-1] == '/' ? '*' : '/*'
			nums = Dir[file_path + suffix].length
			if change_str == true
				nums = nums.next
				nums.to_s.rjust(3, '0')
			end
		end

	end

	#some methods about the Sequel
	no_tasks do

		# == arrange_fields
		#
		# arrange the field with the way of Sequel migration
		# the format of data like this, 
		# ['table_name', 'field1', 'field2', 'field3']
		# ['table_name', 'field1,primary_id', 'field2,String', 'field3,:string,null=false']
		# ['rename', 'old_table', 'new_table]
		# ['drop', 'field1', 'field2', 'field3']
		# ['alter', 'table_name', 'field1', 'field2', 'field3']
		#
		# == returned value
		#
		# :operator, create, alter, drop, rename to the table
		# :table, table name
		# :fields
		def arrange_fields data
			res = {}

			#operator
			operators = [:alter, :rename, :drop]
			res[:operator] = operators.include?(data[0].to_sym) ? data.shift.to_sym : :create

			#table
			if res[:table] == :rename or res[:table] == :drop
				res[:table] = data.join "_"
			else
				res[:table] = data.shift
			end

			#fields
			res[:fields] = []
			res[:fields] = data if data.length > 0
			res
		end
		
		def generate_migration data
				operator 	= data[:operator]
				table		= data[:table]
				fields		= data[:fields]

				content = "Sequel.migration do\n"
				content << "\tchange do\n"

				if operator == :drop or operator == :rename
					content << "\t\t#{operator}_table "
					i = 0
					fields.each do | f |
						content << ", " if i > 0
						content << ":#{f}"
						i = i + 1
					end
					content << "\n"

				elsif operator == :create
					content << "\t\t#{operator}_table(:#{table}) do\n"
					fields.each do | item |
						content << "\t\t\tcolumn :"
						if item.index(",")
 							content << item.gsub(/=/, " => ").gsub(/,/, ", ")
						else
							content << "#{item}, String"
						end
						content << "\n"
					end
					content << "\t\tend\n"

				elsif operator == :alter
					content << "\t\t#{operator}_table(:#{table}) do\n"
					content << "\t\t\t#{fields.shift} :"
					content << fields.join(", :")
					content << "\n"
					content << "\t\tend\n"
				end

				content << "\tend\n"
				content << "end\n"
				content
		end

	end

end
