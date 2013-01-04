module Seimtra

	module Sbase
		#the information about the Seimtra WAS
		Version 			= 	{
			:name			=>	'Seimtra',
			:created		=>	'2011-10-13',
			:alias_name		=>	'3s',
			:version		=>	'0.0.1',
			:author			=>	'Linyu den coolesting',
			:email			=>	'coolesting@gmail.com',
			:hoempage		=>	'https://github.com/coolesting/seimtra',
			:summary		=>	'Seimtra is a web application system.',
			:description	=>	'Seimtra is a web application system.'
		}

		#root directory files
		Files_root			= {
			:seimfile		=> 'Seimfile'
		}

		#the installed files
		Files 				= 	{
			:info			=>	'install/_mods.sfile',
			:readme			=>	'README.md'
		}

		File_installer		=	'install/install.rb',

		#other installed files
		File_install		 = {
			:menu			=>	'install/_menu.sfile'
		}

		File_app		 	= {
			:routes			=>	'applications/routes.rb'
		}

		#the basic folder
		Folders 			= {
			:app			=>	'applications',
			:tpl			=>	'templates',
			:install		=>	'install'
		}

		Folders_others		= {
			:lang			=> 	'languages',
			:migrations		=> 	'migrations'
		}

		Paths				= {
			:config_ms		=> 'c:\.Seimtra',
			:config_lx		=> '~/.Seimtra',
			:docs_tpl		=> 'docs/templates',
			:docs_local		=> '/src/seimtra',
			:docs_remote	=> 'https://github.com/coolesting/seimtra-docs.git'
		}

		Infos 				= {
			#the Seimfile default config option
			:project			=> {
				:status			=> "development",
				:module_focus 	=> 'custom'
			},

			#the default module field
			:module			 	=> {
				:name			=> '',
				:order			=> 9,
				:status 		=> 1,
				:email			=> 'empty',
				:author 		=> 'unknown',
				:created 		=> Time.now,
				:version 		=> '0.0.1',
				:tid 			=> 1,	#tag id
				:dependon		=> '',
				:description	=> 'No description'
			},

			#custom user config file
			:config 			=> {
				:email			=> '',
				:name			=> '',
				:website		=> '',
				:remote_repos 	=> '',
				:local_repos 	=> File.expand_path('~/SeimRepos')
			}
		}

		Root_user 			= {
			:name 			=> 'admin',
			:pawd 			=> 'admin'
		}

		#default basic setting of module
		Settings 			= {
			:lang			=> 'en'
		}

		Status_type 		= ["development", "production", "test"]

		Main_key			= [:primary_key, :index, :foreign_key, :unique]

		Field_type			= {

			:integer		=> 	'integer',
			:string 		=> 	'string',
			:text 			=> 	'text',
			:file			=>	'file',
			:float			=>	'float',
			:datetime		=>	'datetime',
			:date			=>	'date',
			:time			=>	'time',
			:numeric		=>	'numeric',

			:int			=>	'integer',
			:str			=>	'string',
			:dt				=>	'datetime',
			:num			=>	'numeric',
			:pk				=>	'primary_key',
			:fk				=>	'foreign_key',

			:primary_key	=>	'primary_key',
			:foreign_key	=>	'foreign_key',
			:index			=>	'index',
			:unique			=>	'unique'

		}
	end

end
