#!/usr/bin/env python
# -*- coding: UTF-8 -*-

#this file is intended as the main controller for the python pipeline that creates the game files

import subprocess, sys, re
from xml.dom.minidom import parse, parseString
from xml.dom.minidom import getDOMImplementation
import createLevelsFromWorld
import classic2grid
import layoutgrid


from subprocess import call

### Command line interface ###
if __name__ == "__main__":
	if (len(sys.argv) != 4):
		print ('\n\nUsage: %s input_file output_directory\n\n  input_file: name of classic XML '
			'file to be parsed\n  output_directory: output directory. Must exist.\ntypechecker script name') % (sys.argv[0])
		quit()
	infile = sys.argv[1]
	outdirectory = sys.argv[2]
	scriptname = sys.argv[3]

	#separate the levels, assign a level id, rename the level to that id, and create a map file to keep track of connections
	print 'calling separateLevels'
	fileMap = open(outdirectory + '/'+'filemap.xml','w')
	fileMap.write('<files sourcefile="'+infile+'">')
	createLevelsFromWorld.separateLevels(infile, outdirectory, fileMap)
	fileMap.write('</files>')
	fileMap.close()

	fileMap = open(outdirectory + '/'+'filemap.xml','r')
	allxml = parse(fileMap)
	files = allxml.getElementsByTagName('files')
	wx = files[0]
	
	# now walk through each file creating the game files for them
	for file in wx.getElementsByTagName('level'):

		filename = outdirectory + '/' + file.getAttribute('id');

		#Create the layout and constraints files
     		classic2grid.classic2grid(filename, filename);
 
		#Use dot to create the actual layout
     		layoutgrid.layout(filename + 'Layout', filename + 'Layout', False);
 
		#Count nodes and edges, errors, bonus nodes
		command = ['java', '-jar', '/var/www/html/java/DifficultyRater.jar', outdirectory, outdirectory, scriptname]
		rateCmd = subprocess.Popen(command)