ROOTPATH = File.expand_path('../../../', __FILE__)

require 'thor'
require 'seimtra/info'
require 'seimtra/scfg'
require 'seimtra/db'
require 'seimtra/utils'

class SeimtraThor < Thor
	def self.source_root
		ROOTPATH
	end
end

file_exsit = SCFG.load
Dir[ROOTPATH + '/lib/bin/*.rb'].each do |file|
	require file
end

if file_exsit
	Dir[ROOTPATH + '/lib/bin/projects/*.rb'].each do |file|
		require file
	end
end

SeimtraThor.sinit
SeimtraThor.start
SCFG.save
