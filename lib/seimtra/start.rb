ROOTPATH = File.expand_path('../../../', __FILE__)

require 'thor'
require 'seimtra/base'

include Seimtra

require 'seimtra/scfg'
require 'seimtra/db'

#file name
F_INFO = Sbase::Files[:info]
F_README = Sbase::Files[:readme]

class SeimtraThor < Thor

	include Seimtra

	def self.source_root
		ROOTPATH
	end
end

file_exsit = SCFG.load
Dir[ROOTPATH + '/lib/bin/*.rb'].each do | file |
	require file
end

if file_exsit
	Dir[ROOTPATH + '/lib/bin/projects/*.rb'].each do | file |
		require file
	end
end

SeimtraThor.start
SCFG.save
