module Seimtra

	module Sbase
		#the information about the Seimtra WAS
		Version 			= 	{
			:name			=>	'seimtra',
			:created		=>	'2011-10-13',
			:alias_name		=>	'3s',
			:version		=>	'0.0.1',
			:author			=>	'Bruce Deng',
			:email			=>	'coolesting@gmail.com',
			:hoempage		=>	'https://github.com/coolesting/seimtra',
			:summary		=>	'Seimtra is a web application system.',
			:description	=>	'Seimtra is a web application system.'
		}

		#seimtra config file
		File_config			= {
			:seimfile		=> 'Seimfile'
		}

		#generated file when module is created
		File_generated 		= 	{
			:info			=>	'stores/install/_mods',
			:readme			=>	'README.md'
		}

		#installed module files
		File_installer		=	'stores/install.rb',

		#other installed files
		File_installed		= {
			:menu			=>	'stores/install/_menu'
		}

		#application file
		File_logic		 	= {
			:routes			=>	'logics/routes.rb'
		}

		#the basic folder
		Folders 			= {
			:app			=>	'logics',
			:tpl			=>	'views',
			:store			=>	'stores',
			:install		=>	'stores/install'
		}

		Folders_others		= {
			:lang			=>	'stores/lang',
			:tool			=>	'tools'
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
				:tid 			=> 1,
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
