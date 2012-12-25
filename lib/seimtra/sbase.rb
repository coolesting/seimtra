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
			:summary		=>	'no summary, currentlly',
			:description	=>	'Seimtra is a web application system.'
		}

		#root directory files
		Files_root			= {
			:seimfile		=> 'Seimfile'
		}

		#the installed files is required
		Files 				= 	{
			:info			=>	'install/module.sfile',
			:readme			=>	'README.md'
		}

		#the other installeed files is optional
		File_install		 = {
# 			:tag			=>	'install/tag.sfile',
# 			:user			=>	'install/user.sfile',
# 			:setting		=>	'install/setting.sfile',
			:menu			=>	'install/menu.sfile'
		}

		#the required folders
		Folders 			= {
			:app			=>	'applications',
			:tpl			=>	'templates',
			:install		=>	'install'
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
				:load_order		=> 9,
				:opened			=> 'on',
				:status 		=> 'development',
				:email			=> 'empty',
				:author 		=> 'unknown',
				:created 		=> Time.now,
				:version 		=> '0.0.1',
				:group 			=> 'common',
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
