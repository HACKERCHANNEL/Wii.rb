#!/usr/bin/env ruby
#	Wii.rb -- A Wii toolkit written in Ruby
# 
# Author::	Alex Marshall "trap15" (mailto:trap15@raidenii.net)
# Copyright::	Copyright (C) 2010 HACKERCHANNEL
# License::	New BSD License

# A class to handle IMD5 headers.
class IMD5Header < WiiObject
	# Create the object.
	# +data+ is the data to be acted upon.
	def initialize(data)
		@data = data
		@crypt = Crypto.new()
		@tag = ""
		@size = 0
		@hash = ""
	end
	# Check if the IMD5 is valid.
	# Also loads the internal structures with data.
	def check?()
		imd5 = @data.unpack("a4Na8a16")
		@tag = imd5[0]
		@size = imd5[1]
		@hash = imd5[3]
		unless @tag == "IMD5"
			return false
		end
		unless @size == @data[self.length()..-1].length()
			puts "Invalid length (" + @size.to_s + " vs. " + @data[self.length()..-1].length().to_s + "), continuing anyways..."
		end
		unless @crypt.validateMD5Hash(@data[self.length()..-1], @hash)
			puts "Invalid hash, continuing anyways..."
		end
		return true
	end
	# Add an IMD5 header to the data.
	def add()
		@tag = "IMD5"
		@size = @data.length()
		@hash = @crypt.createMD5Hash(@data)
		@data = [@tag, @size, "\0" * 8, @hash].pack("a4Na8a16") + @data
		return @data
	end
	# Remove the IMD5 header from the data.
	def remove()
		@data = @data[self.length()..-1] if(self.check?())
		return @data
	end
	# Dump out the data.
	def dump()
		return @data
	end
	# Length of the IMD5 header.
	def length()
		return 32
	end
end

# A class to handle IMET headers.
class IMETHeader < WiiObject
	attr_accessor :tag, :size, :unk, :sizes, :unk2, :names, :hash
	def initialize(data)
		@data = data
		@crypt = Crypto.new()
		@sizes = []
		@names = []
	end
	# Unpack the header data.
	def unpack()
		tag = @data.unpack("a64a4a60a4")
		unless (tag[1] == "IMET") or (tag[3] == "IMET")
			return false
		end
		if tag[3] == "IMET" # Channel modification thing.
			@data = @data[0x40..-1]
		end
		@imet = @data.unpack("a64a4NN" + "N"*3 + "N" + "a84"*10 + "a588a16")
		@tag = @imet[1]
		@size = @imet[2]
		@unk = @imet[3]
		@sizes[0...3] = @imet[4...7] # Icon, Banner, Sound
		@unk2 = @imet[7]
		for i in (0...10)
			@names[i] = text_conv("UTF-8", "UTF-16BE", @imet[8 + i]) # Multi-language names
		end
		@hash = @imet[19]
		return true
	end
	# Pack the header data.
	def pack()
		return ["\0" * 64, @tag, @size, @unk & 0xFFFFFFFF, @sizes[0], @sizes[1], @sizes[2], 
		 @unk2, @names[0], @names[1], @names[2], @names[3], @names[4], @names[5], @names[6],
		 @names[7], @names[8], @names[9], "\0" * 588, @hash].pack("a64a4NN" + "N"*3 + "N" + "a84"*10 + "a588a16")
	end
	# Check if the IMET is valid.
	# Also loads the internal structures with data.
	def check?()
		return false if !self.unpack()
		unless @unk == 3
			puts "Unk doesn't match (" + @unk.to_s + " vs. 3). Continuing anyways..."
		end
		unless @unk2 == 0
			puts "Unk2 doesn't match (" + @unk2.to_s + " vs. 0). Continuing anyways..."
		end
		newdata = @data.clone
		newdata[@size-0x10,@size] = "\0" * 16
		unless @crypt.validateMD5Hash(@data[0, @size], @hash)
			puts "Invalid hash, continuing anyways..."
		end
		return true
	end
	# Adds an IMET header to the data.
	def add(sizes, names)
		@tag = "IMET"
		@size = 0x00000600
		@unk = 00000003
		@sizes[0..2] = sizes[0..2]
		@unk2 = 0
		for i in (0...10)
			@names[i] = text_conv("UTF-16BE", "UTF-8", names[i]) # Multi-language names
		end
		@hash = "\0" * 16
		imet = self.pack()
		@hash = @crypt.createMD5Hash(imet[0,@size])
		@data = self.pack() + @data
		return @data
	end
	# Removes the IMET header from the data.
	def remove()
		@data = @data[self.length()..-1] if(self.check?())
		return @data
	end
	# Dumps the current data.
	def dump()
		return @data
	end
	# Length of IMET headers.
	def length()
		return @size
	end
end
