#!/usr/bin/env ruby
#	EXbanner -- A banner file extractor using Wii.rb
# 
# Copyright (C)2010	Alex Marshall "trap15" <trap15@raidenii.net>
# 
# All rights reserved, HACKERCHANNEL

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

puts "Extracting..."
u8 = U8Archive.new()
cmp = Compression.new()
imet = IMETHeader.new(readFile(ARGV[0]))
unless imet.check?()
	puts "Not a valid banner file (no IMET header)"
	exit
end
puts "Icon Size: " + imet.sizes[0].to_s
puts "Banner Size: " + imet.sizes[1].to_s
puts "Sound Size: " + imet.sizes[2].to_s
puts "Names:"
puts "	Japanese: " + imet.names[0]
puts "	English: " + imet.names[1]
puts "	German: " + imet.names[2]
puts "	French: " + imet.names[3]
puts "	Spanish: " + imet.names[4]
puts "	Italian: " + imet.names[5]
puts "	Dutch: " + imet.names[6]
puts "	Simple Chinese: " + imet.names[7]
puts "	Traditional Chinese: " + imet.names[8]
puts "	Korean: " + imet.names[9]
puts "	Unk1: " + imet.names[10]
puts "	Unk2: " + imet.names[11]
puts "	Unk3: " + imet.names[12]
puts "	Unk4: " + imet.names[13]
puts "	Unk5: " + imet.names[14]
puts "	Unk6: " + imet.names[15]
puts "	Unk7: " + imet.names[16]
cmp.load(imet.remove())
if cmp.compressed?() or $COMPRESSED
	cmp.uncompress()
end
u8.load(cmp.dump())
u8.dumpDir(ARGV[1])

puts "Extracting banner.bin"
u8 = U8Archive.new()
imd5 = IMD5Header.new(readFile(ARGV[1] + "/meta/banner.bin"))
imd5.remove() if imd5.check?()
cmp.load(imd5.dump())
cmp.uncompress() if cmp.compressed?()
imd5 = IMD5Header.new(cmp.dump)
imd5.remove() if imd5.check?()
u8.load(imd5.dump())
u8.dumpDir(ARGV[1] + "/meta/banner")
puts "Extracted banner.bin!"

puts "Extracting icon.bin"
u8 = U8Archive.new()
cmp.loadFile(ARGV[1] + "/meta/icon.bin")
imd5.remove() if imd5.check?()
cmp.load(imd5.dump())
cmp.uncompress() if cmp.compressed?()
imd5 = IMD5Header.new(cmp.dump)
imd5.remove() if imd5.check?()
u8.load(imd5.dump())
u8.dumpDir(ARGV[1] + "/meta/icon")
puts "Extracted icon.bin!"

puts "Extracted!"
