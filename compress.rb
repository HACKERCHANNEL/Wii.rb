#!/usr/bin/env ruby
#	Wii.rb -- A Wii toolkit written in Ruby
# 
# Author::	Alex Marshall "trap15" (mailto:trap15@raidenii.net)
# Copyright::	Copyright (C) 2010 HACKERCHANNEL
# License::	New BSD License

# A class to handle all compression.
class Compression < WiiObject
	TYPE_LZ77 = 1
	# Load the compressor with data.
	def load(data)
		@data = data
	end
	# Dump out the current data.
	def dump()
		return @data
	end
	# Checks if the current data is compressed.
	def compressed?()
		if @data[0..3] == "LZ77"
			return true
		else
			return false
		end
	end
	# Uncompresses the current data and returns the new data.
	def uncompress()
		@data = @data[4..-1] if @data[0..3] == "LZ77"
		hdr = @data.unpack("V")[0]
		uncomp_len = hdr >> 8
		comp_type = (hdr >> 4) & 0xF
		@data = @data[4..-1]
		if comp_type == Compression::TYPE_LZ77
			return unlz77(uncomp_len)
		else
			raise ArgumentError, "Compression type not supported " + comp_type.to_s
		end
	end
	# Compresses the current data and returns the new data.
	def compress(type)
		uncomp_len = @data.length()
		comp_type = type
		hdr  = uncomp_len << 8
		hdr |= comp_type << 4
		
		if comp_type == Compression::TYPE_LZ77
			return lz77(hdr)
		else
			raise ArgumentError, "Compression type not supported " + comp_type.to_s
		end
	end

# LZ77
	# Uncompresses the current data using LZ77.
	def unlz77(uncomp_len)
		newdata = ""
		progress = 0
		srcptr = 0
		print "Decompressing...\n"
		while newdata.length() < uncomp_len
			flags = @data[srcptr...srcptr+1].unpack("C")[0]
			srcptr += 1
			for i in (0...8)
				if (flags & 0x80) == 0x80
					inf = @data[srcptr...srcptr+2].unpack("n")[0]
					srcptr += 2
					num = 3 + ((inf >> 12) & 0xF)
					disp = inf & 0xFFF
					ptr = newdata.length() - disp - 1
					if newdata.length() + num > uncomp_len
						num = uncomp_len - newdata.length()
					end
					for l in (0...num)
						newdata += newdata[ptr...ptr+1]
						ptr += 1
						if newdata.length() >= uncomp_len
							break
						end
					end
				else
					newdata += @data[srcptr...srcptr+1]
					srcptr += 1
				end
				flags <<= 1
				break if newdata.length() >= uncomp_len
			end
			print "\r" + (100 * newdata.length() / uncomp_len).to_s
		end
		print "\rDecompressed!\n"
		@data = newdata
		return @data
	end
	# Compresses the current data using LZ77. (Not available yet)
	def lz77(newdata)
		newdata = ""
		newdata += 'L' + 'Z' + '7' + '7'
		newdata += [ hdr ].pack("V")
		
		raise NotImplementedError, "Compression is not supported currently"
		
		@data = newdata
		return @data
	end
end
