#!/usr/bin/env ruby
#	Decapitate -- A header remover using Wii.rb
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

puts "Decapitating..."
imet = IMETHeader.new(readFile(ARGV[0]))
imet.remove() if imet.check?()
imd5 = IMD5Header.new(imet.dump())
imd5.remove() if imd5.check?()
imet = IMETHeader.new(imd5.dump())
imet.dumpFile(ARGV[1])
puts "Decapitated!"
