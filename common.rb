#!/usr/bin/env ruby
#	Wii.rb -- A Wii toolkit written in Ruby
# 
# Author::	Alex Marshall "trap15" (mailto:trap15@raidenii.net)
# Copyright::	Copyright (C) 2010 HACKERCHANNEL
# License::	New BSD License

require 'openssl'
require 'digest/md5'
require 'digest/sha1'
require 'iconv'

# Gives the remaining area to pad for +len+ to be aligned by +width+.
def pad_length(len, width)
	if len % width == 0
		return 0
	end
	return (width - (len % width))
end

# Align +addr+ to +width+ bytes.
def align(addr, width)
	return addr + pad_length(addr, width)
end

# Clamp +val+ to be within +min+ and +max+.
def clamp(val, min, max)
	return min if val < min
	return max if val > max
	return val
end

# Convert +intext+ from +inform+ text encoding to +outform+ encoding.
def text_conv(outform, inform, intext)
	return Iconv.iconv(outform, inform, intext).join
end

# The Wii common key.
def commonKey()
	return "\xEB\xE4\x2A\x22\x5E\x85\x93\xE4\x48\xD9\xC5\x45\x73\x81\xAA\xF7"
end

# The Korean Wii common key.
def koreanKey() # Kekekekeke
	return "\x63\xB8\x2B\xB4\xF4\x61\x4E\x2E\x13\xF2\xFE\xFB\xBA\x4C\x9B\x7E"
end

# Opens a file, reads the contents, then closes the file and returns the contents.
def readFile(fname)
	inf = File.new(fname, "r")
	ret = inf.read()
	inf.close
	return ret
end

# Opens a file, writes the contents, then closes the file.
def writeFile(fname, data)
	inf = File.new(fname, "w+")
	ret = inf.write(data)
	inf.close
	return ret
end

# Handles all cryptographic functionality.
class Crypto
	def initialize()
		@align = 64
		@crypter = OpenSSL::Cipher::Cipher.new("AES-256-CBC")
	end
	# Decrypt data.
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
	# Encrypt data.
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
	# Decrypt a content.
	def decryptContent(titlekey, idx, data)
		iv = [ idx ].pack("n") + "\x00" * 14
		return self.decryptData(titlekey, iv, data)
	end
	# Decrypt a title key.
	def decryptTitleKey(commonkey, tid, enckey)
		iv = [ (tid >> 32) & 0xFFFFFFFF ].pack("N") + [ tid & 0xFFFFFFFF ].pack("N") + "\x00" * 8
		return self.decryptData(commonkey, iv, enckey)
	end
	# Decrypt a content.
	def encryptContent(titlekey, idx, data)
		iv = [ idx ].pack("n") + "\x00" * 14
		return self.encryptData(titlekey, iv, data)
	end
	# Create a SHA1 hash of +data+.
	def createSHAHash(data)
		return Digest::SHA1.digest(data)
	end
	# Create an MD5 hash of +data+.
	def createMD5Hash(data)
		return Digest::MD5.digest(data)
	end
	# Validate a SHA1 hash.
	def validateSHAHash(data, hash)
		newhash = self.createSHAHash(data)
		if newhash == hash
			return true
		else
			return false
		end
	end
	# Validate an MD5 hash.
	def validateMD5Hash(data, hash)
		newhash = self.createMD5Hash(data)
		if newhash == hash
			return true
		else
			return false
		end
	end
end

# The general class that all other classes inherit from
class WiiObject
	# Wraps load and readFile.
	def loadFile(fname)
		return self.load(readFile(fname))
	end
	# Wraps dump and writeFile.
	def dumpFile(fname)
		return writeFile(fname, self.dump())
	end
	# def load(data)
	# def dump()
end

class WiiArchive < WiiObject
	# Wraps _dumpDir.
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
	
	# Wraps _loadDir.
	def loadDir(dirname)
		old = Dir.getwd()
		Dir.chdir(dirname)
		ret = self._loadDir(dirname)
		Dir.chdir(old)
		return ret
	end
	# def _loadDir(dirname)
end
