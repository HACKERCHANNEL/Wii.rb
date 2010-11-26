#!/usr/bin/env ruby
#	U8em -- A U8 archive extractor using Wii.rb
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
puts "Extracting..."
cmp = Compression.new()
imd5 = IMD5Header.new(readFile(ARGV[0]))
imd5.remove() if imd5.check?()
cmp.load(imd5.dump())
cmp.uncompress() if cmp.compressed?()
imd5 = IMD5Header.new(cmp.dump)
imd5.remove() if imd5.check?()
u8.load(imd5.dump())
u8.dumpDir(ARGV[1])
puts "Extracted!"
