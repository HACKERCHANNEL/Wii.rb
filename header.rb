#!/usr/bin/env ruby
#	Wii.rb -- Wii stuff for Ruby
# 
# Copyright (C)2010	Alex Marshall "trap15" <trap15@raidenii.net>
# 
# All rights reserved, HACKERCHANNEL

class IMD5Header
	def initialize(data)
		@data = data
		@crypt = Crypto.new()
	end
	def check?()
		data = @data.clone
		for i in (0..data.length())
			if data[0] != 0
				break
			end
			data = data[1..-1]
		end
		imd5 = data.unpack("a4Na8a16")
		tag = imd5[0]
		size = imd5[1]
		pad = imd5[2]
		hash = imd5[3]
		if tag != "IMD5"
			return false
		end
		if size != @data.length()
			puts "Invalid length (" + size.to_s + " vs. " + @data.length().to_s + "), continuing anyways..."
		end
		newhash = @crypt.createMD5Hash(@data[self.length()..-1])
		if hash != newhash
			puts "Invalid hash, continuing anyways..."
		end
		return true
	end
	def add()
		tag = "IMD5"
		size = @data.length()
		hash = @crypt.createMD5Hash(@data)
		@data = [tag, size, "\0" * 8, hash].pack("A4NA8A16") + @data
		return @data
	end
	def remove()
		for i in (0..@data.length())
			if data[0] != 0
				break
			end
			@data = @data[1..-1]
		end
		@data = @data[self.length()..-1]
		return @data
	end
	def length()
		return 32
	end
end
