#!/usr/bin/env ruby
#	Wii.rb -- Wii stuff for Ruby
# 
# Copyright (C)2010	Alex Marshall "trap15" <trap15@raidenii.net>
# 
# All rights reserved, HACKERCHANNEL

$DEBUG = false
$COMPRESSED = false
args = ARGV.clone
while true
	arg = args.shift
	break if !arg
	ARGV.shift
	if (arg == "--debug") or (arg == "-d")
		$DEBUG = true
	elsif (arg == "--compressed") or (arg == "-c")
		$COMPRESSED = true
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
cmp.loadFile(ARGV[0])
if cmp.compressed?() or $COMPRESSED
	cmp.uncompress()
	u8.load(cmp.dump())
else
	u8.loadFile(ARGV[0])
end
u8.dumpDir(ARGV[1])
puts "Extracted!"
