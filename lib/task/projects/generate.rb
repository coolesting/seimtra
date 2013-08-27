class SeimtraThor < Thor

	long_desc <<-DOC
	== Description

	Create the scaffold to specifing module

	3s g table_name field1 field2 field3 -s=scaffold_name 


	Exampla 01, create a post table with the fields title, content to current module you focus,

	3s g post title content -a
	3s g post title body


	Example 02, just create a form for putting data to database

	3s g myform title content -s=form


	Example 03, or maybe create a view for displaying the data, no changing the database structure.

	3s g module mid name -s=view

	certainly, the article table is existing in current database.


	Example 04, create multiple scaffold at once, such as admin and view scaffold

	3s g post title body -s=admin,view 

	DOC

	desc "generate [SCAFFOLD_NAME] [TABLE_NAME] [FIELDS]", "Generate a scaffold for module"
	method_option :to, :type => :string, :aliases => '-t'
	method_option :layout, :type => :string, :aliases => '-l'
	method_option :scaffold, :type => :string, :aliases => '-s', :default => ''
	method_option :autocomplete, :type => :boolean, :aliases => '-a'
	method_option :with, :type => :hash, :default => {}, :aliases => '-w'
	method_option :menu, :type => :hash, :default => {}, :aliases => '-m'
	method_option :norun, :type => :boolean, :aliases => '-nr'
	map 'g' => :generate
	def generate *argv
		error 'the arguments must more than 2.' unless argv.length > 1

		db					= Sapi.new
		module_name 		= options[:to] ? options[:to] : get_module
		scaffold			= 'admin'

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
		@t[:others]			= data[:others]

		files 				= {}

		#load all of scaffolds
		scaffolds = {}
		Dir["modules/*/#{Sbase::Folders_others[:tool]}/*"].each do | path |
			scaffolds[path.split("/").last] = path
		end

		scfg = project_config

		#get scaffold
		scaffold = scfg[:default_scaffold] if scfg[:default_scaffold]
		scaffold = options[:scaffold] unless options[:scaffold] == ''

		multi_scaffolds = []
		if scaffold.length > 2 and scaffold.index(",")
			multi_scaffolds = scaffold.split(",")
		else
			multi_scaffolds << scaffold
		end

		multi_scaffolds.each do | scaffold |

			error "The scaffold called ''#{scaffold}'' is not existing." unless scaffolds.include? scaffold
			scaf_path = Dir.pwd + '/' + scaffolds[scaffold]

			#set the layout
			tcfg = Sfile.read("#{scaf_path}/config.sfile")
			@t[:layout] = scfg[:layout] if scfg.include? :layout
			@t[:layout] = tcfg[:layout] if tcfg.include? :layout
			@t[:layout] = options[:layout] if options.include?(:layout)

			#render routes and template file
			Dir["#{scaf_path}/*.tpl", "#{scaf_path}/*.app"].each do | source |

                filename    = source.split("/").last
                name, ext   = filename.split('.')
                if ext == 'tpl'
                    target = "modules/#{module_name}/#{Sbase::Folders[:tpl]}/#{@t[:file_name]}_#{name}.slim"
                elsif ext == 'app'
                    target = "modules/#{module_name}/#{Sbase::Folders[:app]}/#{@t[:file_name]}.rb"
                end

				unless File.exist?(target)
					template(source, target)
				else
					content = get_erb_content source, false
					append_to_file target, content
				end
			end

			#render install menu
			menufile = "#{scaf_path}/menu.install"
			if File.exist? menufile
				menu_path = "modules/#{module_name}/#{Sbase::File_installed[:menu]}"
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
