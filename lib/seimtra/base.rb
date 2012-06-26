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
			:info			=>	'install/info.cfg',
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
			:lang			=>	'languages',
			:install		=>	'install'
		}

		Paths				= {
			:config_ms		=> 'c:\.Seimtra',
			:config_lx		=> '~/.Seimtra',
			:tpl_system		=> 'docs/templates/system',
			:docs_repos		=> 'https://github.com/coolesting/seimtra-docs.git',
			:temp_repos		=> '',
			:mod_repos		=> ''
		}

		#module info that stores in each root directory of module as name info.cfg
		Module_info			 = {
			:load_order		=> 9,
			:module_name	=> '',
			:opened			=> 'on',
			:status 		=> 'development',
			:email			=> 'empty',
			:author 		=> 'unknown',
			:created 		=> Time.now,
			:version 		=> '0.0.1',
			:group_name 	=> 'common',
			:description	=> 'No description',
			:dependon		=> ''
		}

		#the Seimfile default config option
		Project_info 		= {
			:log 			=> 'off',
			:log_path 		=> Dir.pwd + '/log/default',
			:module_focus 	=> 'front',
			:local_repos 	=> File.expand_path('~/SeimRepos'),
			:remote_repos 	=> ''
		}

		#custom user config file
		Config 				= {
			:email			=> '',
			:name			=> '',
			:website		=> ''
		}

		#default basic setting of module
		Settings 			= {
			:lang			=> 'en'
		}

		Block 				=	{
			:display		=> ["center", "header", "footer", "left", "right", "none"],
			:type			=> ["link", "text"]
		}

		Required_module 	= ["system", "front", "users"] 

	end

end
