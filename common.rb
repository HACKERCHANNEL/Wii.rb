#!/usr/bin/env ruby
#	Wii.rb -- Wii stuff for Ruby
# 
# Copyright (C)2010	Alex Marshall "trap15" <trap15@raidenii.net>
# 
# All rights reserved, HACKERCHANNEL

require 'openssl'
require 'digest/md5'
require 'digest/sha1'
require 'iconv'

def pad_length(len, width)
	if len % width == 0
		return 0
	end
	return (width - (len % width))
end

def align(addr, width)
	return addr + pad_length(addr, width)
end

def clamp(val, min, max)
	return min if val < min
	return max if val > max
	return val
end

def text_conv(outform, inform, intext)
	return Iconv.iconv(outform, inform, intext).join
end

def commonKey()
	return "\xEB\xE4\x2A\x22\x5E\x85\x93\xE4\x48\xD9\xC5\x45\x73\x81\xAA\xF7"
end

def koreanKey() # Kekekekeke
	return "\x63\xB8\x2B\xB4\xF4\x61\x4E\x2E\x13\xF2\xFE\xFB\xBA\x4C\x9B\x7E"
end

def readFile(fname)
	inf = File.new(fname, "r")
	ret = inf.read()
	inf.close
	return ret
end

def writeFile(fname, data)
	inf = File.new(fname, "w+")
	ret = inf.write(data)
	inf.close
	return ret
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
		return Digest::SHA1.digest(data)
	end
	def createMD5Hash(data)
		return Digest::MD5.digest(data)
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
		return self.load(readFile(fname))
	end
	def dumpFile(fname)
		return writeFile(fname, self.dump())
	end
	# def load(data)
	# def dump()
end

class WiiArchive < WiiObject
	def dumpDir(dirname)
		unless File.directory?(dirname)
			Dir.mkdir(dirname)
		end
		old = Dir.getwd()
		Dir.chdir(dirname)
		ret = self._dumpDir(dirname)
		Dir.chdir(old)
		return ret
	end
	# def _dumpDir(dirname)
	def loadDir(dirname)
		old = Dir.getwd()
		Dir.chdir(dirname)
		ret = self._loadDir(dirname)
		Dir.chdir(old)
		return ret
	end
	# def _loadDir(dirname)
end
