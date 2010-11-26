#!/usr/bin/env ruby
#	PXbanner -- A banner packer using Wii.rb
# 
# Author::	Alex Marshall "trap15" (mailto:trap15@raidenii.net)
# Copyright::	Copyright (C) 2010 HACKERCHANNEL
# License::	New BSD License

$DEBUG = false
$DISC = true
args = ARGV.clone
while true
	arg = args.shift
	break if !arg
	ARGV.shift
	if (arg == "--debug") or (arg == "-d")
		$DEBUG = true
	elsif (arg == "--channel") or (arg == "-c")
		$DISC = false
	else
		ARGV.push(arg)
	end
end

unless ARGV.length >= 2
	puts "Invalid arguments."
	exit
end

require File.dirname(__FILE__) + "/../Wii.rb"

sizes = []
puts "Packing..."
puts "Packing icon.bin"
u8 = U8Archive.new()
u8.loadDir(ARGV[0] + "/meta/icon")
imd5 = IMD5Header.new(u8.dump())
imd5.add()
imd5.check?()
imd5.dumpFile(ARGV[0] + "/meta/icon.bin")
puts "Packed!"

puts "Packing banner.bin"
u8 = U8Archive.new()
u8.loadDir(ARGV[0] + "/meta/banner")
imd5 = IMD5Header.new(u8.dump())
imd5.add()
imd5.check?()
imd5.dumpFile(ARGV[0] + "/meta/banner.bin")
puts "Packed!"

sizes.push(File.size(ARGV[0] + "/meta/icon.bin") - 0x20)
sizes.push(File.size(ARGV[0] + "/meta/banner.bin") - 0x20)
sizes.push(File.size(ARGV[0] + "/meta/sound.bin") - 0x20)

names = []
for i in (0...10)
	names.push(ARGV[2])
end
puts "Packing banner"
u8 = U8Archive.new()
u8.addDirectory("meta")
u8.addFile(ARGV[0] + "/meta/icon.bin", "meta/icon.bin")
u8.addFile(ARGV[0] + "/meta/banner.bin", "meta/banner.bin")
u8.addFile(ARGV[0] + "/meta/sound.bin", "meta/sound.bin")
imet = IMETHeader.new(u8.dump())
imet.add(sizes, names)
if !$DISC
	data = "PXbanner_Wii.rb!" + "\0" * 32 + "HACKERCHANNEL\0\0\0"
else
	data = ""
end
data += imet.dump()
writeFile(ARGV[1], data)
puts "Packed!"
puts "Packing complete!"
