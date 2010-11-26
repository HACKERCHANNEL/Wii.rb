#!/usr/bin/env ruby
#	decomp -- An LZ77 decompressor using Wii.rb
# 
# Author::	Alex Marshall "trap15" (mailto:trap15@raidenii.net)
# Copyright::	Copyright (C) 2010 HACKERCHANNEL
# License::	New BSD License

def usage()
	puts "Usage:"
	puts "	" + $0 + " input.bin output.bin"
end

puts "decomp -- An LZ77 decompressor using Wii.rb"
puts "Copyright (C) 2010 HACKERCHANNEL"
puts "Written by Alex Marshall \"trap15\" <trap15@raidenii.net>"
puts ""

$DEBUG = false
args = ARGV.clone
while true
	arg = args.shift
	break if !arg
	ARGV.shift
	if (arg == "--debug") or (arg == "-d")
		$DEBUG = true
	elsif (arg == "--help") or (arg == "-h")
		usage()
		exit
	else
		ARGV.push(arg)
	end
end

unless ARGV.length >= 2
	print "Invalid arguments."
	usage()
	exit
end

require File.dirname(__FILE__) + "/../Wii.rb"

cmp = Compression.new()
cmp.loadFile(ARGV[0])
cmp.uncompress()
cmp.dumpFile(ARGV[1])
