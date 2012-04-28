module Seimtra

	module Base

		#The information about the Seimtra WAS
		Version = {
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

		#The file struction of this system
		Files = {
			:info			=>	'infos.cfg',
			:readme			=>	'README.md'
		}

		Folders = {
			:application	=>	'applications',
			:templates		=>	'templates',
			:languages		=>	'languages'
		}

		#module info that stores in each root directory of module as name info.cfg
		Info = {
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
		Seimfile = {
			:log 			=> 'off',
			:log_path 		=> Dir.pwd + '/log/default',
			:module_focus 	=> 'front',
			:local_repos 	=> File.expand_path('~/SeimRepos'),
			:remote_repos 	=> ''
		}

		#custom user config file
		Config = {
			:email			=> '',
			:name			=> '',
			:website		=> ''
		}

		#default basic setting of module
		Settings = {
			:lang			=> 'en'
		}

	end

end
