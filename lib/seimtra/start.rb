ROOTPATH = File.expand_path('../../../', __FILE__)

require 'thor'
require 'seimtra/info'
require 'seimtra/scfg'

class SeimtraThor < Thor
	def self.source_root
		ROOTPATH
	end
end

SCFG.init
Dir[ROOTPATH + '/lib/bin/*.rb'].each do |file|
	require file
end
if SCFG.get('status') != 'production'
	Dir[ROOTPATH + '/lib/bin/development/*.rb'].each do |file|
		require file
	end
end

SeimtraThor.sinit
SeimtraThor.start
SCFG.save
