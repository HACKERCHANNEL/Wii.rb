#!/usr/bin/env ruby
#	decapitate -- A header remover using Wii.rb
# 
# Author::	Alex Marshall "trap15" (mailto:trap15@raidenii.net)
# Copyright::	Copyright (C) 2010 HACKERCHANNEL
# License::	New BSD License

def usage()
	puts "Usage:"
	puts "	" + $0 + " input.arc outfolder"
end

puts "decapitate -- A header remover using Wii.rb"
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

puts "Decapitating..."
imet = IMETHeader.new(readFile(ARGV[0]))
imet.remove() if imet.check?()
imd5 = IMD5Header.new(imet.dump())
imd5.remove() if imd5.check?()
imet = IMETHeader.new(imd5.dump())
imet.dumpFile(ARGV[1])
puts "Decapitated!"
