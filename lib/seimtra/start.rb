ROOTPATH = File.expand_path('../../../', __FILE__)
SCONFIGS = '/configs/Seimfile'

require 'thor'
require 'seimtra/version'
require 'seimtra/scfg'
SCFG.init

class SeimtraThor < Thor
	def self.source_root
		ROOTPATH
	end
end

Dir[ROOTPATH + '/lib/bin/*.rb'].each do |file|
	require file
end
if SCFG.get('status') == 'development'
	Dir[ROOTPATH + '/lib/bin/development/*.rb'].each do |file|
		require file
	end
end

SeimtraThor.start
SCFG.save
