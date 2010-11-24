#!/usr/bin/env ruby
#	Wii.rb -- Wii stuff for Ruby
# 
# Copyright (C)2010	Alex Marshall "trap15" <trap15@raidenii.net>
# 
# All rights reserved, HACKERCHANNEL

class Compression < WiiObject
	TYPE_LZ77 = 1
	def initialize()
	end
	def load(data)
		@data = data
	end
	def dump()
		return @data
	end
	def length()
		return 8
	end
	def compressed?()
		if @data[0..3] == "LZ77"
			return true
		else
			return false
		end
	end
	def uncompress()
		if @data[0..3] == "LZ77"
			@data = @data[4..-1]
		end
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
				if newdata.length() >= uncomp_len
					break
				end
			end
			print "\r" + (100 * newdata.length() / uncomp_len).to_s
		end
		print "\rDecompressed!\n"
		@data = newdata
		return @data
	end
	def lz77(newdata)
		newdata = ""
		newdata += 'L' + 'Z' + '7' + '7'
		newdata += [ hdr ].pack("V")
		
		raise NotImplementedError, "Compression is not supported currently"
		
		@data = newdata
		return @data
	end
end
