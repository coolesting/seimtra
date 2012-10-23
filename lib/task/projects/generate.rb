class SeimtraThor < Thor

	long_desc <<-DOC
	== Description

	Create the scaffold for current module

	3s g table_name field1 field2 field3

	create a post to article module

	3s g post pid:integer title content:text created:time changed:time -t=article

	or

	3s g post title content:text -a -t=article

	#create by specifying scaffold
	3s g post title body --scaffold=front

	DOC

	desc "generate [TABLE_NAME] [FIELDS]", "Generate a scaffold for module"
	method_option :to, :type => :string, :aliases => '-t'
	method_option :scaffold, :type => :string, :aliases => '-s'
	method_option :layout, :type => :string, :aliases => '-l'
	method_option :autocomplete, :type => :boolean, :aliases => '-a'
	method_option :with, :type => :hash, :default => {}, :aliases => '-w'
	method_option :menu, :type => :hash, :default => {}, :aliases => '-m'
	method_option :norun, :type => :boolean
	map 'g' => :generate
	def generate *argv

		error 'At least two more arguments.' unless argv.length > 2

		db					= Db.new
		module_name 		= options[:to] ? options[:to] : get_module

		auto				= options.autocomplete? ? true : false
		data				= db.arrange_fields argv, auto

		#set the template variables
		@t					= {}
		@t[:module_name]	= module_name
		@t[:layout]			= module_name
		@t[:file_name]		= data[:table]
		@t[:table_name]		= data[:table]

		#arrage the data fields
		@t[:key_id]			= data[:fields][0]
		@t[:fields]			= data[:fields]
		@t[:types]			= data[:types]
		@t[:htmls]			= data[:htmls]
		@t[:assoc]			= data[:assoc]

		files 				= {}

		#load all of scaffolds
		scaffolds = {}
		Dir["modules/*/scaffolds/*"].each do | path |
			scaffolds[path.split("/").last] = path
		end

		scfg = Sfile.read(Dir.pwd + "/Seimfile")

		#choose a scaffold, like --scaffold=front, by default that is system
		scaffold = options.include?(:scaffold) ? "#{options[:scaffold]}" : scfg[:default_scaffold]
		scaf_path = Dir.pwd + '/' + scaffolds[scaffold]

		if scaffold

			#set the layout
			tcfg = Sfile.read("#{scaf_path}/config.sfile")
			@t[:layout] = tcfg[:layout] if tcfg.include? :layout
			@t[:layout] = options[:layout] if options.include?(:layout)

			#copy the template to the targer file
			Dir["#{scaf_path}/*.tpl"].each do | source |

				filename = source.split("/").last
				if filename == 'view.tpl'
					target = "modules/#{module_name}/templates/#{@t[:layout]}_#{@t[:file_name]}.slim"
				elsif filename == 'form.tpl'
					target = "modules/#{module_name}/templates/#{@t[:layout]}_#{@t[:file_name]}_form.slim"
				elsif filename == 'route.tpl'
					target = "modules/#{module_name}/applications/#{@t[:file_name]}.rb"
				end

				unless File.exist?(target)
					template(source, target)
				else
					content = get_erb_content source
					append_to_file target, content
				end
			end

			#menu.install
			@t[:menu] = {}
			@t[:menu][:name] = options[:menu].include?('name') ? options[:menu]['menu'] : @t[:file_name]
			@t[:menu][:des]	= options[:menu].include?('des') ? options[:menu]['des'] : "No description about the #{@t[:file_name]}"

			path = "modules/#{module_name}/#{Sbase::File_install[:menu]}"
			menufile = "#{scaf_path}/menu.install"
			if File.exist? menufile
				content = File.read(menufile)
				menu = ""
				eval("menu = \"#{content}\"")
				append_to_file path, menu
			end

		end

		run "3s db #{data[:table]} #{argv.join(' ')} --to=#{module_name}"

		unless options.norun?
			run "3s update #{module_name}"
		end
	end

end
