#!/usr/bin/env ruby
#	EXbanner -- A banner extractor using Wii.rb
# 
# Author::	Alex Marshall "trap15" (mailto:trap15@raidenii.net)
# Copyright::	Copyright (C) 2010 HACKERCHANNEL
# License::	New BSD License

def usage()
	puts "Usage:"
	puts "	" + $0 + " banner.bnr outfolder"
end

puts "EXbanner -- A banner extractor using Wii.rb"
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
imd5 = IMD5Header.new(readFile(ARGV[1] + "/meta/icon.bin"))
imd5.remove() if imd5.check?()
cmp.load(imd5.dump())
cmp.uncompress() if cmp.compressed?()
imd5 = IMD5Header.new(cmp.dump)
imd5.remove() if imd5.check?()
u8.load(imd5.dump())
u8.dumpDir(ARGV[1] + "/meta/icon")
puts "Extracted icon.bin!"

puts "Extracted!"
