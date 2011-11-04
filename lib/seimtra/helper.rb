class Shelper

	attr_accessor :name, :keys, :vals, :vars

	def initialize(argv, with)
		@vars = {}
		@name = argv.shift
		@keys = @vals = []
		@with = with

		argv.each do |item|
			key, val = item.split(":")
			@keys << key
			@vals << val
			@vars[val] = key 
		end
	end

end
