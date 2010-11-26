#!/usr/bin/env ruby
#	Wii.rb -- Wii stuff for Ruby
# 
# Copyright (C)2010	Alex Marshall "trap15" <trap15@raidenii.net>
# 
# All rights reserved, HACKERCHANNEL

class ContentMap < WiiObject
	def initialize()
		@namemap = {}
		@hashmap = {}
		@array = []
	end
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
	def contentByHash(hash)
		return @hashmap[hash]
	end
	def contentByName(name)
		return @namemap[name]
	end
	def contentCount()
		return @count
	end
	def dump()
		data = ""
		for i in (0...@count)
			data += [ array[i*2 + 0], array[i*2 + 1] ].pack("a8a20")
		end
		return data
	end
	def length()
		return 8
	end
end
