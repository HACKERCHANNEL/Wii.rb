#!/usr/bin/env ruby
#	Wii.rb -- Wii stuff for Ruby
# 
# Copyright (C)2010	Alex Marshall "trap15" <trap15@raidenii.net>
# 
# All rights reserved, HACKERCHANNEL

class U8Header
	attr_accessor :tag, :rootnode_off, :header_sz, :data_off, :pad
	def initialize()
		@tag = " " * 4
		@rootnode_off = 0
		@header_sz = 0
		@data_off = 0
		@pad = "\0" * 16
	end
	def pack()
		return [ @tag, @rootnode_off, @header_sz, @data_off, @pad ].pack("A4NNNA16")
	end
	def unpack(data)
		array = data.unpack("a4NNNa16")
		@tag = array[0]
		@rootnode_off = array[1]
		@header_sz = array[2]
		@data_off = array[3]
		@pad = array[4]
	end
	def length()
		return 32
	end
end

class U8Node
	TYPE_FILE	= 0x0000
	TYPE_FOLDER	= 0x0100
	attr_accessor :type, :name_off, :data_off, :size
	def pack()
		return [ @type, @name_off, @data_off, @size ].pack("nnNN")
	end
	def unpack(data)
		array = data.unpack("nnNN")
		@type = array[0]
		@name_off = array[1]
		@data_off = array[2]
		@size = array[3]
	end
	def length()
		return 12
	end
end

class U8Archive < WiiArchive
	def initialize()
		@files = []
	end
	def load(data)
		header = U8Header.new()
		header.unpack(data[0,0 + header.length()])
		offset = header.rootnode_off
		
		rootnode = U8Node.new()
		rootnode.unpack(data[offset,offset + rootnode.length()])
		offset += rootnode.length()
		
		nodes = []
		for i in (0...rootnode.size - 1)
			node = U8Node.new()
			node.unpack(data[offset,offset + node.length()])
			offset += node.length()
			nodes.push(node)
		end
		strings = data[offset,offset + header.data_off - header.length() - (rootnode.length() * rootnode.size)]
		offset += strings.length()
		
		recursion = [rootnode.size]
		recursiondir = ["."]
		counter = 0
		for node in nodes
			counter += 1
			name = (strings[node.name_off,strings.length()].split(/\x00/))[0]
			if node.type == U8Node::TYPE_FOLDER
				recursion.push(node.size)
				recursiondir.push(name.clone)
				@files.push(recursiondir.join('/'))
				@files.push(nil) # No data for directories
				
				if $DEBUG == true
					puts "Dir: " + name
				end
			elsif node.type == U8Node::TYPE_FILE
				offset = node.data_off
				@files.push(recursiondir.join('/') + '/' + name.clone)
				@files.push(data[offset,offset + node.size])
				
				if $DEBUG == true
					puts "File: " + name
				end
			else
				raise TypeError, name + " U8 node type is not file nor folder. Is " + node.type.to_s()
			end
			
			if $DEBUG == true
				puts "Data Offset: " + node.data_off.to_s
				puts "Size: " + node.size.to_s
				puts "Name Offset: " + node.name_off.to_s
				puts ""
			end
			sz = recursion.pop()
			if sz != counter + 1
				recursion.push(sz)
			else
				recursiondir.pop()
			end
		end
	end
	def _dumpDir(dirname)
		while true
			file = @files.shift
			data = @files.shift
			break if !file
			if $DEBUG == true
				puts file
			end
			if data == nil # Folder
				if $DEBUG == true
					puts "Folder"
				end
				if not File.directory?(file)
					Dir.mkdir(file)
				end
			else
				if $DEBUG == true
					puts "File"
				end
				outf = File.new(file, "w+")
				outf.write(data)
				outf.close
			end
		end
	end
end
