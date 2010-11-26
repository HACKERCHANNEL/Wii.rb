#!/usr/bin/env ruby
#	Wii.rb -- A Wii toolkit written in Ruby
# 
# Author::	Alex Marshall "trap15" (mailto:trap15@raidenii.net)
# Copyright::	Copyright (C) 2010 HACKERCHANNEL
# License::	New BSD License

# A class to handle the /shared1/content.map file.
class ContentMap < WiiObject
	# A hash indexed by content name containing the map between name and hash.
	attr_reader :namemap
	# A hash indexed by content hash containing the map between name and hash.
	attr_reader :hashmap
	# The amount of contents in the map.
	attr_reader :count
	def initialize()
		@namemap = {}
		@hashmap = {}
		@array = []
		@count = 0
	end
	# Loads the content.map from data.
	def load(data)
		@count = data.length() / 28
		for i in (0...@count)
			entry = data[i*28,(i+1)*28].unpack("a8a20")
			@namemap[entry[0]] = entry[1]
			@hashmap[entry[1]] = entry[0]
			array[i*2 + 0] = entry[0]
			array[i*2 + 1] = entry[1]
		end
	end
	# Dumps out the content.map data.
	def dump()
		data = ""
		for i in (0...@count)
			data += [ array[i*2 + 0], array[i*2 + 1] ].pack("a8a20")
		end
		return data
	end
end
