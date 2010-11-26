#!/usr/bin/env ruby
#	U8pack -- A U8 archive packer using Wii.rb
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

u8 = U8Archive.new()
puts "Packing..."
u8.loadDir(ARGV[0])
u8.dumpFile(ARGV[1])
puts "Packed!"
