ROOTPATH = File.expand_path('../../../', __FILE__)

require 'thor'
require 'seimtra/info'
require 'seimtra/scfg'

class SeimtraThor < Thor
	def self.source_root
		ROOTPATH
	end
end

file_exsit = SCFG.init
Dir[ROOTPATH + '/lib/bin/*.rb'].each do |file|
	require file
end
if file_exsit != false
	Dir[ROOTPATH + '/lib/bin/common/*.rb'].each do |file|
		require file
	end

	Dir[ROOTPATH + '/lib/bin/' + SCFG.get('status') + '/*.rb'].each do |file|
		require file
	end
end

SeimtraThor.sinit
SeimtraThor.start
SCFG.save
