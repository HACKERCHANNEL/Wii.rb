#!/usr/bin/env ruby

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

require File.dirname(__FILE__) + "/Wii.rb"

u8 = U8Archive.new()
puts "Extracting..."
u8.loadFile(ARGV[0])
u8.dumpDir(ARGV[1])
puts "Done!"
