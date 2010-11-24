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
		@tag = ""
		@size = 0
		@hash = ""
	end
	def check?()
		imd5 = @data.unpack("a4Na8a16")
		@tag = imd5[0]
		@size = imd5[1]
		@hash = imd5[3]
		unless @tag == "IMD5"
			return false
		end
		unless @size == @data.length()
			puts "Invalid length (" + @size.to_s + " vs. " + @data.length().to_s + "), continuing anyways..."
		end
		newhash = @crypt.createMD5Hash(@data[self.length()..-1])
		unless @hash == newhash
			puts "Invalid hash, continuing anyways..."
		end
		return true
	end
	def add()
		@tag = "IMD5"
		@size = @data.length()
		@hash = @crypt.createMD5Hash(@data)
		@data = [@tag, @size, "\0" * 8, @hash].pack("A4NA8A16") + @data
		return @data
	end
	def remove()
		@data = @data[self.length()..-1] if(self.check?())
		return @data
	end
	def dump()
		return @data
	end
	def length()
		return 32
	end
end

class IMETHeader
	attr_accessor :tag, :unk, :sizes, :unk2, :names, :hash
	def initialize(data)
		@data = data
		@crypt = Crypto.new()
		@sizes = []
		@names = []
	end
	def check?()
		tag = @data.unpack("a64a4")
		if tag[1] == "IMET"
			imet = @data.unpack("a64a4NN" + "N"*3 + "N" + "a84"*17 + "a16")
		else
			imet = @data.unpack("a128a4NN" + "N"*3 + "N" + "a84"*17 + "a16")
		end
		@tag = imet[1]
		@unk = (imet[2] << 32) | (imet[3])
		@sizes[0...3] = imet[4...7] # Icon, Banner, Sound
		@unk2 = imet[7]
		for i in (0...17)
			@names[i] = text_conv("UTF-8", "UTF-16BE", imet[8 + i]) # Multi-language names
		end
		@hash = imet[25]
		unless @tag == "IMET"
			return false
		end
		unless @unk == 0x0000060000000003
			puts "Unk doesn't match (" + @unk.to_s + " vs. 6597069766659). Continuing anyways..."
		end
		unless @unk2 == 0
			puts "Unk2 doesn't match (" + @unk2.to_s + " vs. 0). Continuing anyways..."
		end
		newhash = @crypt.createMD5Hash(@data[0x40...0x640])
		unless @hash == newhash
			puts "Invalid hash, continuing anyways..."
		end
		return true
	end
	def add(sizes, names)
		@tag = "IMET"
		@unk = 0x0000060000000003
		@sizes[0..2] = sizes[0..2]
		@unk2 = 0
		for i in (0...17)
			@names[i] = text_conv("UTF-16BE", "UTF-8", names[i]) # Multi-language names
		end
		@hash = "\0" * 16
		imet = ["\0" * 128, @tag, @unk >> 32, @unk & 0xFFFFFFFF, @sizes[0], @sizes[1], @sizes[2], 
		 @unk2, @names[0], @names[1], @names[2], @names[3], @names[4], @names[5], @names[6],
		 @hash].pack("A128A4NN" + "N"*3 + "N" + "A84"*17 + "A16")
		@hash = @crypt.createMD5Hash(imet[0x40...0x640])
		imet = ["\0" * 128, @tag, @unk >> 32, @unk & 0xFFFFFFFF, @sizes[0], @sizes[1], @sizes[2], 
		 @unk2, @names[0], @names[1], @names[2], @names[3], @names[4], @names[5], @names[6],
		 @hash].pack("A128A4NN" + "N"*3 + "N" + "A84"*17 + "A16")
		@data = imet + @data
		return @data
	end
	def remove()
		@data = @data[self.length()..-1] if(self.check?())
		return @data
	end
	def dump()
		return @data
	end
	def length()
		tag = @data.unpack("a64a4")
		if tag[1] == "IMET"
			return 0x600
		else
			return 0x640
		end
	end
end
