#!/usr/bin/env ruby
#	Wii.rb -- Wii stuff for Ruby
# 
# Copyright (C)2010	Alex Marshall "trap15" <trap15@raidenii.net>
# 
# All rights reserved, HACKERCHANNEL

class U8Header
	attr_accessor :tag, :rootnode_off, :header_sz, :data_off, :pad
	def initialize()
		@tag = ""
		@rootnode_off = 0
		@header_sz = 0
		@data_off = 0
		@pad = "\0" * 16
	end
	def pack()
		return [ @tag, @rootnode_off, @header_sz, @data_off, @pad ].pack("a4NNNa16")
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
	def initialize()
		@type = 0
		@name_off = 0
		@data_off = 0
		@size = 0
	end
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
	attr_accessor :files, :filesizes
	def initialize()
		@filearray = []
		@files = {}
		@filesizes = {}
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
				@files[recursiondir.join('/')] = nil
				@filesizes[recursiondir.join('/')] = 0
				@filearray.push(recursiondir.join('/'))
				@filearray.push(nil) # No data for directories
				@filearray.push(0) # No size for directories
				
				if $DEBUG
					puts "Dir: " + name
				end
			elsif node.type == U8Node::TYPE_FILE
				offset = node.data_off
				@files[recursiondir.join('/') + '/' + name.clone] = data[offset..offset + node.size]
				@filesizes[recursiondir.join('/') + '/' + name.clone] = node.size
				@filearray.push(recursiondir.join('/') + '/' + name.clone)
				@filearray.push(data[offset..offset + node.size])
				@filearray.push(node.size)
				
				if $DEBUG
					puts "File: " + name
				end
			else
				raise TypeError, name + " U8 node type is not file nor folder. Is " + node.type.to_s()
			end
			
			if $DEBUG
				puts "Data Offset: " + node.data_off.to_s
				puts "Size: " + node.size.to_s
				puts "Name Offset: " + node.name_off.to_s
			end
			sz = recursion.last
			while sz == counter + 1
				if $DEBUG
					puts "Popped directory " + recursiondir.last
				end
				recursion.pop()
				recursiondir.pop()
				
				sz = recursion.last
			end
			if $DEBUG
				puts ""
			end
		end
	end
	def _dumpDir(dirname)
		files = @filearray.clone
		while true
			file = files.shift
			break if !file
			data = files.shift
			size = files.shift
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
				outf.write(data[0,size])
				outf.close
			end
		end
	end
	def _loadDir(dirname)
		dirs = File.join("**", "*")
		dirlist = Dir.glob(dirs)
		while true
			dir = dirlist.shift
			break if !dir
			if $DEBUG
				puts dir
			end
			@filearray.push(dir)
			if File.directory?(dir)
				if $DEBUG
					puts "  Dir"
				end
				@files[dir] = nil
				@filesizes[dir] = 0
				@filearray.push(nil)
				@filearray.push(0)
			else
				if $DEBUG
					puts "  File"
				end
				@files[dir] = readFile(dir)
				@filesizes[dir] = File.size(dir)
				@filearray.push(readFile(dir))
				@filearray.push(File.size(dir))
			end
		end
	end
	def addFile(filename, target)
		@files[target] = readFile(filename)
		@filesizes[target] = File.size(filename)
		@filearray.push(target)
		@filearray.push(readFile(filename))
		@filearray.push(File.size(filename))
	end
	def addDirectory(target)
		@files[target] = nil
		@filesizes[target] = 0
		@filearray.push(target)
		@filearray.push(nil)
		@filearray.push(0)
	end
	def delEntry(target)
		ctr = 0
		@files.delete(target)
		@filesizes.delete(target)
		@filearray.each {|f|
			if ctr % 3 == 0
				if f == target
					@filearray.delete_at(ctr)
					@filearray.delete_at(ctr)
					@filearray.delete_at(ctr)
					ctr -= 1
				end
			end
			ctr += 1
		}
	end
	def dump()
		head = U8Header.new()
		rootnode = U8Node.new()
		head.tag = "U\xAA8-"
		head.rootnode_off = 0x20
		rootnode.type = U8Node::TYPE_FOLDER
		nodes = []
		strings = "\x00"
		filedata = ""
		files = @filearray.clone
		files2 = @filearray.clone
		while true
			file = files.shift
			break if !file
			data = files.shift
			size = files.shift
			if $DEBUG
				puts file
			end
			node = U8Node.new()
			recurse = file.count "/"
			if file.rindex("/") == nil
				name = file.clone
			else
				name = file[file.rindex("/") + 1..-1]
			end
			node.name_off = strings.length()
			if $DEBUG
				puts name
			end
			strings += name + "\x00"
			if data == nil # Directory
				if $DEBUG
					puts "Directory"
				end
				node.type = U8Node::TYPE_FOLDER
				node.data_off = recurse
				node.size = nodes.length() + 2
				if $DEBUG
					puts "  Position: " + node.size.to_s
				end
				files3 = files2.clone
				while true
					file2 = files3.shift
					break if !file2
					if $DEBUG
						puts "  " + file2
					end
					files3.shift
					files3.shift
					if file2[0..file.length()] == (file + "/")
						if $DEBUG
							puts "    YES"
						end
						node.size += 1
					end
				end
				if $DEBUG
					puts "  Size: " + node.size.to_s
				end
			else # File
				if $DEBUG
					puts "File"
				end
				node.type = U8Node::TYPE_FILE
				node.data_off = filedata.length()
				# 32 bytes seems to work best for "fuzzyness". ???
				node.size = size
				filedata += data + ("\x00" * pad_length(node.size, 32))
				if $DEBUG
					puts "  Size: " + node.size.to_s
				end
			end
			if $DEBUG
				puts ""
			end
			nodes.push(node)
		end
		head.header_sz = ((nodes.length() + 1) * rootnode.length()) + strings.length()
		head.data_off = align(head.header_sz + head.rootnode_off, 64)
		rootnode.size = nodes.length() + 1
		
		for i in (0...nodes.length())
			if nodes[i].type == U8Node::TYPE_FILE
				nodes[i].data_off += head.data_off
			end
		end
		dat = ""
		dat += head.pack()
		dat += rootnode.pack()
		nodes.map {|node| dat += node.pack() }
		dat += strings
		dat += "\x00" * (head.data_off - head.rootnode_off - head.header_sz)
		dat += filedata
		
		return dat
	end
end
