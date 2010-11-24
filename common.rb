#!/usr/bin/env ruby
#	Wii.rb -- Wii stuff for Ruby
# 
# Copyright (C)2010	Alex Marshall "trap15" <trap15@raidenii.net>
# 
# All rights reserved, HACKERCHANNEL

require 'openssl'
require 'digest/md5'
require 'digest/sha1'

def align(addr, width)
	return addr + (width - (addr % width))
end

def clamp(val, min, max)
	return min if val < min
	return max if val > max
	return val
end

class Crypto
	def initialize()
		@align = 64
		@crypter = OpenSSL::Cipher::Cipher.new("AES-256-CBC")
	end
	def decryptData(key, iv, data, doalign = true)
		if ((data.length() % @align) != 0) and doalign
			data = data + ("\x00" * (align(data.length(), @align) - data.length()))
		end
		@crypter.decrypt
		@crypter.key = key
		@crypter.iv = iv
		d = @crypter.update(data)
		d << @crypter.final
		return d
	end
	def encryptData(key, iv, data, doalign = true)
		if ((data.length() % @align) != 0) and doalign
			data = data + ("\x00" * (align(data.length(), @align) - data.length()))
		end
		@crypter.encrypt
		@crypter.key = key
		@crypter.iv = iv
		e = @crypter.update(data)
		e << @crypter.final
		return e
	end
	def decryptContent(titlekey, idx, data)
		iv = [ idx ].pack("n") + "\x00" * 14
		return self.decryptData(titlekey, iv, data)
	end
	def decryptTitleKey(commonkey, tid, enckey)
		iv = [ (tid >> 32) & 0xFFFFFFFF ].pack("N") + [ tid & 0xFFFFFFFF ].pack("N") + "\x00" * 8
		return self.decryptData(commonkey, iv, enckey)
	end
	def encryptContent(titlekey, idx, data)
		iv = [ idx ].pack("n") + "\x00" * 14
		return self.encryptData(titlekey, iv, data)
	end
	def createSHAHash(data)
		return Digest::SHA1.hexdigest(data)
	end
	def createMD5Hash(data)
		return Digest::MD5.hexdigest(data)
	end
	def validateSHAHash(data, hash)
		newhash = self.createSHAHash(data)
		if newhash == hash
			return true
		else
			return false
		end
	end
end

class WiiObject
	def loadFile(fname)
		inf = File.new(fname, "r")
		ret = self.load(inf.read())
		inf.close
		return ret
	end
	def dumpFile(fname)
		outf = File.new(fname, "w+")
		outf.write(self.dump())
		outf.close
		return fname;
	end
	# def load(data)
	# def dump()
end

class WiiArchive < WiiObject
	def dumpDir(dirname)
		if not File.directory?(dirname)
			Dir.mkdir(dirname)
		end
		old = Dir.getwd()
		Dir.chdir(dirname)
		ret = self._dumpDir(dirname)
		Dir.chdir(old)
		return ret
	end
	# def _dumpDir(dirname)
	# def loadDir(dirname)
end

class WiiFile < WiiArchive
	def initialize()
		@type = nil
	end
	def discover()
		@fcc = @data.unpack("A4")
		print @fcc[0..3]
		case @fcc[0..3]
			when "LZ77"
				@type = LZ77
			when "U\xAA8-"
				@type = U8Archive
			when "IMD5"
				@type = IMD5Header
			when "IMET"
				@type = IMETHeader
			else
				return nil
		end
		ret = @type.load(@data)
		@type.remove()
		return ret
	end
	def load(data)
		@data = data
		for i in (0..@data.length())
			if @data[0] != 0
				break
			end
			@data = @data[1..-1]
		end
		return self.discover()
	end
	def dump()
		return @type.dump()
	end
	def _dumpDir(dirname)
		return @type._dumpDir(dirname)
	end
	def loadDir(dirname)
		return @type.loadDir(dirname)
	end
end
