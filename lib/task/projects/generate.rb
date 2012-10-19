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
	3s g post title body --with=scaffold:front

	DOC

	desc "generate [TABLE_NAME] [FIELDS]", "Generate a scaffold for module"
	method_option :to, :type => :string, :aliases => '-t'
	method_option :autocomplete, :type => :boolean, :aliases => '-a'
	method_option :with, :type => :hash, :default => {}
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

		#add a scaffold
		#--with=scaffold:front
		scaffold = options[:with]['scaffold'] ? "#{options[:with]['scaffold']}" : 'system'

		if scaffold

			#set the layout
			tpl_cfg = Sfile.read "#{ROOTPATH}/#{Sbase::Paths[:docs_tpl]}/#{scaffold}/config.sfile"
			@t[:layout] = tpl_cfg[:layout] if tpl_cfg.include? :layout

			#copy the template to the targer file
			Dir["#{ROOTPATH}/#{Sbase::Paths[:docs_tpl]}/#{scaffold}/*.tpl"].each do | source |

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

			#add content to menu.sfile
			menu_name	= options[:name] ? options[:name] : @t[:file_name]
			menu_des	= options[:description] ? options[:description] : "No description about the #{@t[:file_name]}"

			path 		= "modules/#{module_name}/#{Sbase::File_install[:menu]}"

			menu 		= "\nname=#{menu_name}\n"
			menu 		+= "prename=#{module_name}\n"
			menu 		+= "type=#{@t[:layout]}\n"
			menu 		+= "link=/#{@t[:layout]}/#{@t[:file_name]}\n"
			menu 		+= "description=#{menu_des}\n"

			append_to_file path, menu

		end

		run "3s db #{data[:table]} #{argv.join(' ')} --to=#{module_name}"

		unless options.norun?
			run "3s update #{module_name}"
		end
	end

end
