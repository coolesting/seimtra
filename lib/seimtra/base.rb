module Seimtra

	module Sbase

		#the information about the Seimtra WAS
		Version 			= 	{
			:name			=>	'Seimtra',
			:created		=>	'2011-10-13',
			:alias_name		=>	'3s',
			:version		=>	'0.0.1',
			:author			=>	'Bruce deng coolesting',
			:email			=>	'coolesting@gmail.com',
			:hoempage		=>	'https://github.com/coolesting/seimtra',
			:summary		=>	'no summary, currentlly',
			:description	=>	'Seimtra is a web application system.'
		}

		#the file struction of this system is required
		Files 				= 	{
			:info			=>	'install/module.cfg',
			:readme			=>	'README.md'
		}

		#the files under the install folder
		File_install		 = {
			:setting		=>	'install/setting.cfg',
			:panel			=>	'install/panel.list',
			:block			=>	'install/block.list'
		}

		#file type of scfg class
		File_type 			= [:cfg, :list] 

		#the required folders
		Folders 			= {
			:app			=>	'applications',
			:tpl			=>	'templates',
			:install		=>	'install'
		}

		Paths				= {
			:config_ms		=> 'c:\.Seimtra',
			:config_lx		=> '~/.Seimtra',
			:tpl_system		=> 'docs/templates/system',
			:docs_local		=> '/src/seimtra'
			:docs_remote	=> 'https://github.com/coolesting/seimtra-docs.git'
		}

		Infos 				= {
			#the Seimfile default config option
			:project			=> {
				:log 			=> 'off',
				:log_path 		=> Dir.pwd + '/log/default',
				:module_focus 	=> 'front'
			},

			#the default vaule of module field
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


		#default basic setting of module
		Settings 			= {
			:lang			=> 'en'
		}

		Block 				=	{
			:display		=> ["center", "header", "footer", "left", "right", "none"],
			:type			=> ["link", "text"]
		}

	end

end
