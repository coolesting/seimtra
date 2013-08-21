ROOTPATH = File.expand_path('../../../', __FILE__)

require 'thor'
require 'seimtra/sbase'

include Seimtra

require 'seimtra/sfile'
require 'seimtra/db'

class SeimtraThor < Thor

	include Seimtra

	def self.source_root
		ROOTPATH
	end
end

#load the base task
Dir[ROOTPATH + '/lib/task/*.rb'].each do | file |
	require file
end

#load the task for project
if File.exist? Sbase::File_config[:seimfile]
	Dir[ROOTPATH + '/lib/task/projects/*.rb'].each do | file |
		require file
	end
end

SeimtraThor.start
