#!/usr/bin/env ruby
#	Decomp -- An LZ77 decompressor using Wii.rb
# 
# Author::	Alex Marshall "trap15" (mailto:trap15@raidenii.net)
# Copyright::	Copyright (C) 2010 HACKERCHANNEL
# License::	New BSD License

$DEBUG = false
args = ARGV.clone
while true
	arg = args.shift
	break if !arg
	ARGV.shift
	if (arg == "--debug") or (arg == "-d")
		$DEBUG = true
	else
		ARGV.push(arg)
	end
end

unless ARGV.length >= 2
	puts "Invalid arguments."
	exit
end

require File.dirname(__FILE__) + "/../Wii.rb"

cmp = Compression.new()
cmp.loadFile(ARGV[0])
cmp.uncompress()
cmp.dumpFile(ARGV[1])
