class SeimtraThor < Thor

	long_desc <<-DOC
	== Description

	Create the scaffold to specifing module

	3s g scaffold_name table_name field1 field2 field3


	Exampla 01, create a post table withe field title, content to current module you focus,
	the '-' is default scaffold name

	3s g - post title content -a


	Example 02, just create a form for putting data to database

	3s g form myform title content


	Example 03, or maybe create a view, and display the data, no changing the database structure.

	3s g view article title content

	certainly, the article table is existing in current database.

	DOC

	desc "generate [TABLE_NAME] [FIELDS]", "Generate a scaffold for module"
	method_option :to, :type => :string, :aliases => '-t'
	method_option :layout, :type => :string, :aliases => '-l'
	method_option :autocomplete, :type => :boolean, :aliases => '-a'
	method_option :with, :type => :hash, :default => {}, :aliases => '-w'
	method_option :menu, :type => :hash, :default => {}, :aliases => '-m'
	method_option :norun, :type => :boolean
	map 'g' => :generate
	def generate *argv

		error 'the arguments must more than 2.' unless argv.length >= 3

		db					= Db.new
		module_name 		= options[:to] ? options[:to] : get_module
		scaffold			= argv.shift

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

		#set the default scaffold, like --scaffold=form, by default, that is admin scaffold
		scaffold = scfg[:default_scaffold] if scaffold == '-'
		scaf_path = Dir.pwd + '/' + scaffolds[scaffold]

		if scaffold

			#set the layout
			tcfg = Sfile.read("#{scaf_path}/config.sfile")
			@t[:layout] = tcfg[:layout] if tcfg.include? :layout
			@t[:layout] = scfg[:layout] if scfg.include? :layout
			@t[:layout] = options[:layout] if options.include?(:layout)

			#render routes and template file
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

			#render install menu
			menufile = "#{scaf_path}/menu.install"
			if File.exist? menufile
				menu_path = "modules/#{module_name}/#{Sbase::File_install[:menu]}"
				@t[:menu] = {}
				@t[:menu][:name] = options[:menu].include?('name') ? options[:menu]['menu'] : @t[:file_name]
				@t[:menu][:des]	= options[:menu].include?('des') ? options[:menu]['des'] : "No description about the #{@t[:file_name]}"
				content = File.read(menufile)
				menu = ""
				eval("menu = \"#{content}\"")
				append_to_file menu_path, menu
			end

			#run the db
			isrun = tcfg.include?(:run) ? tcfg[:run] : 'on'
			isrun = 'off' if options.norun? 
			if isrun == 'on'
				run "3s db #{data[:table]} #{argv.join(' ')} --to=#{module_name}"
				run "3s update #{module_name}"
			end
		end

	end

end
